#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"

module HtmlArtifacts
  PROFILES = %w[explainer ui-mock].freeze

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

    def initialize(html, profile:)
      @html = html
      @profile = profile
      @errors = []
    end

    def validate!
      @errors << "unknown profile '#{@profile}'" unless PROFILES.include?(@profile)
      validate_structure
      validate_self_containment
      validate_images
      validate_ids_and_anchors
      validate_scripts if PROFILES.include?(@profile)

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

    def validate_images
      images = @html.scan(/<img\b[^>]*>/im)
      return if images.empty?

      if @profile != "explainer"
        @errors << "image element is forbidden"
        return
      end
      directive = csp_content[/img-src\s+([^;]+)/, 1].to_s.split
      @errors << "img-src must allow data images" unless directive.include?("data:")
      @errors << "img-src contains a forbidden source" unless (directive - ["data:"]).empty?

      images.each_with_index do |tag, index|
        label = "image #{index + 1}"
        src = attribute_value(tag, "src")
        alt = attribute_value(tag, "alt")
        width = attribute_value(tag, "width")
        height = attribute_value(tag, "height")
        @errors << "#{label} alt is missing" if alt.nil?
        @errors << "#{label} srcset is forbidden" if attribute_value(tag, "srcset")
        @errors << "#{label} dimensions are missing" unless width&.match?(/\A[1-9]\d*\z/) && height&.match?(/\A[1-9]\d*\z/)
        match = src&.match(/\Adata:(image\/(?:png|jpeg|webp));base64,([A-Za-z0-9+\/=]+)\z/)
        unless match
          @errors << "#{label} must use an embedded PNG, JPEG, or WebP data URI"
          next
        end
        begin
          bytes = Base64.strict_decode64(match[2])
        rescue ArgumentError
          @errors << "#{label} contains invalid base64"
          next
        end
        @errors << "#{label} exceeds 5 MiB" if bytes.bytesize > 5 * 1024 * 1024
        valid_magic = case match[1]
                      when "image/png" then bytes.start_with?("\x89PNG\r\n\x1a\n".b)
                      when "image/jpeg" then bytes.start_with?("\xff\xd8".b)
                      when "image/webp" then bytes.start_with?("RIFF".b) && bytes.byteslice(8, 4) == "WEBP"
                      end
        @errors << "#{label} media type does not match its bytes" unless valid_magic
      end
    end

    def validate_scripts
      scripts = inline_scripts
      directive = csp_content[/script-src\s+([^;]+)/, 1].to_s

      if scripts.empty?
        @errors << "script-src must be none when no script is present" unless directive.split.include?("'none'")
        return
      end

      @errors << "script-src none cannot be used when script is present" if directive.split.include?("'none'")

      if @profile == "explainer"
        @errors << "unsafe-inline is forbidden for explainer" if directive.split.include?("'unsafe-inline'")
        validate_script_hashes(scripts, directive, "renderer script CSP hash is missing")
      elsif !directive.split.include?("'unsafe-inline'")
        validate_script_hashes(scripts, directive, "ui-mock inline script requires unsafe-inline or matching CSP hashes")
      end
    end

    def validate_script_hashes(scripts, directive, message)
      scripts.each do |script|
        hash = Base64.strict_encode64(Digest::SHA256.digest(script))
        @errors << message unless directive.split.include?("'sha256-#{hash}'")
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

  class CLI
    def self.run(argv, out: $stdout, err: $stderr)
      profile = nil
      if argv.first == "--profile"
        argv.shift
        profile = argv.shift
      end
      raise ArgumentError, usage unless profile && argv.length == 1

      path = File.expand_path(argv.fetch(0))
      raise ArgumentError, "HTML file not found: #{path}" unless File.file?(path)

      Validator.new(File.read(path, encoding: "UTF-8"), profile: profile).validate!
      out.puts "Valid HTML artifact: #{path} (#{profile})"
      0
    rescue ValidationError => e
      err.puts "Validation failed:"
      e.errors.each { |error| err.puts "- #{error}" }
      2
    rescue ArgumentError, Errno::EACCES => e
      err.puts "Error: #{e.message}"
      2
    end

    def self.usage
      "usage: validate_html.rb --profile <explainer|ui-mock> <html>"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  exit HtmlArtifacts::CLI.run(ARGV)
end
