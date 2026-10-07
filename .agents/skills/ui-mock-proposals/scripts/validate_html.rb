#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"

module UiMockHtml
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super(errors.join("\n"))
    end
  end

  class Validator
    FORBIDDEN_PATTERNS = {
      "external script" => /<script\b[^>]*\bsrc\s*=/i,
      "external stylesheet" => /<link\b[^>]*\brel\s*=\s*["']?stylesheet/i,
      "iframe element" => /<iframe\b/i,
      "object element" => /<object\b/i,
      "embed element" => /<embed\b/i,
      "media element" => /<(?:video|audio|source|track)\b/i,
      "image element" => /<img\b/i,
      "inline event handler" => /<[a-z][^>]*\son[a-z][a-z0-9:_-]*\s*=/im,
      "CSS import" => /@import\b/i,
      "remote CSS resource" => /url\s*\(\s*["']?https?:/i,
      "automatic refresh" => /<meta\b[^>]*\bhttp-equiv\s*=\s*["']refresh["']/i,
      "top-level navigation" => /\btarget\s*=\s*["']_top["']/i
    }.freeze
    SCRIPT_FORBIDDEN_PATTERNS = {
      "network API" => /\b(?:fetch|XMLHttpRequest|WebSocket|EventSource|sendBeacon)\s*\(/i,
      "browser storage" => /\b(?:localStorage|sessionStorage|indexedDB)\b/i,
      "cookie access" => /\bdocument\.cookie\b/i,
      "parent browsing context access" => /(?:(?<![.\w$])(?:window|self|globalThis)\s*(?:\.\s*(?:parent|top)\b|\[\s*["'](?:parent|top)["']\s*\])|(?<![.\w$])(?:parent|top)\s*(?:\.|\[))/i
    }.freeze

    def initialize(html)
      @html = html
      @errors = []
    end

    def validate!
      validate_structure
      validate_self_containment
      validate_portable_references
      validate_ids_and_anchors
      validate_scripts

      raise ValidationError, @errors unless @errors.empty?

      true
    end

    private

    def validate_structure
      @errors << "doctype is missing" unless @html.match?(/\A(?:\uFEFF)?\s*<!doctype html>/i)
      @errors << "html lang is missing" unless @html.match?(/<html\b[^>]*\blang\s*=\s*["'][^"']+["']/i)
      @errors << "viewport meta is missing" unless @html.match?(/<meta\b[^>]*\bname\s*=\s*["']viewport["']/i)
      @errors << "CSP is missing" if csp_content.empty?
      @errors << "HTML closing tags are missing" unless @html.match?(%r{</body>}i) && @html.match?(%r{</html>\s*\z}i)
    end

    def validate_self_containment
      FORBIDDEN_PATTERNS.each do |label, pattern|
        @errors << "#{label} is forbidden" if @html.match?(pattern)
      end
      inline_scripts.each do |script|
        SCRIPT_FORBIDDEN_PATTERNS.each do |label, pattern|
          @errors << "#{label} is forbidden" if script.match?(pattern)
        end
      end
      @errors << "connect-src must be none" unless csp_content.match?(/(?:\A|;)\s*connect-src\s+'none'(?:\s|;|\z)/)
      @errors << "object-src must be none" unless csp_content.match?(/(?:\A|;)\s*object-src\s+'none'(?:\s|;|\z)/)
      @errors << "base-uri must be none" unless csp_content.match?(/(?:\A|;)\s*base-uri\s+'none'(?:\s|;|\z)/)
      @errors << "form-action must be none" unless csp_content.match?(/(?:\A|;)\s*form-action\s+'none'(?:\s|;|\z)/)
    end

    def validate_ids_and_anchors
      ids = attribute_values("id")
      duplicates = ids.tally.select { |_id, count| count > 1 }.keys
      @errors << "duplicate IDs: #{duplicates.join(', ')}" unless duplicates.empty?

      targets = attribute_values("href").filter_map do |href|
        href.delete_prefix("#") if href.start_with?("#") && href.length > 1
      end
      missing = targets.uniq - ids.uniq
      @errors << "missing internal anchor targets: #{missing.join(', ')}" unless missing.empty?
    end

    def validate_portable_references
      references = @html.scan(
        /\b(?:src|href|poster|action|data)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'`=<>]+))/im
      ).map { |double_quoted, single_quoted, unquoted| double_quoted || single_quoted || unquoted }
      references.concat(@html.scan(/url\(\s*(["']?)(.*?)\1\s*\)/im).map { |_quote, value| value })
      forbidden = references.select { |reference| non_portable_reference?(reference.strip) }.uniq
      return if forbidden.empty?

      @errors << "non-portable references are forbidden: #{forbidden.join(', ')}"
    end

    def non_portable_reference?(reference)
      reference.match?(/\Afile:/i) ||
        reference.start_with?("/", "~", "\\") ||
        reference.match?(/\A[a-z]:[\\\/]/i)
    end

    def validate_scripts
      scripts = inline_scripts
      directive = csp_content[/script-src\s+([^;]+)/, 1].to_s

      if scripts.empty?
        @errors << "script-src must be none when no script is present" unless directive.split.include?("'none'")
        return
      end

      @errors << "script-src none cannot be used when script is present" if directive.split.include?("'none'")

      return if directive.split.include?("'unsafe-inline'")

      scripts.each do |script|
        hash = [Digest::SHA256.digest(script)].pack("m0")
        @errors << "ui-mock inline script requires unsafe-inline or matching CSP hashes" unless directive.split.include?("'sha256-#{hash}'")
      end
    end

    def csp_content
      @csp_content ||= begin
        tag = @html.scan(/<meta\b[^>]*>/im).find do |meta|
          attribute_value(meta, "http-equiv")&.casecmp?("Content-Security-Policy")
        end
        tag ? attribute_value(tag, "content").to_s : ""
      end
    end

    def inline_scripts
      @inline_scripts ||= @html.scan(/<script\b(?![^>]*\bsrc\s*=)[^>]*>(.*?)<\/script>/im).flatten
    end

    def attribute_values(name)
      @html.scan(/\b#{Regexp.escape(name)}\s*=\s*(["'])(.*?)\1/im).map { |_quote, value| value }
    end

    def attribute_value(fragment, name)
      match = fragment.match(/\b#{Regexp.escape(name)}\s*=\s*(["'])(.*?)\1/im)
      match && match[2]
    end
  end
end
