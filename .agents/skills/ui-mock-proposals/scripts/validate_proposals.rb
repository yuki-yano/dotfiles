#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../_shared/html-artifacts/scripts/validate_html"

module UiMockProposals
  ID_PATTERN = /\A[a-z][a-z0-9]*(?:-[a-z0-9]+)*\z/

  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super(errors.join("\n"))
    end
  end

  class Validator
    def initialize(html)
      @html = html
      @errors = []
    end

    def validate!
      validate_shared_contract
      validate_current
      validate_proposals
      raise ValidationError, @errors unless @errors.empty?

      true
    end

    private

    def validate_shared_contract
      HtmlArtifacts::Validator.new(@html, profile: "ui-mock").validate!
    rescue HtmlArtifacts::ValidationError => e
      @errors.concat(e.errors)
    end

    def validate_current
      @errors << "current baseline anchor is missing" unless current_element?
      @errors << "current baseline navigation link is missing" unless attribute_values("href").include?("#current")
    end

    def current_element?
      @html.scan(/<(?:section|article)\b[^>]*>/im).any? do |tag|
        attribute_value(tag, "id") == "current"
      end
    end

    def validate_proposals
      proposals = proposal_elements
      @errors << "must contain 2 to 5 proposals" unless proposals.length.between?(2, 5)

      ids = proposals.map { |proposal| proposal.fetch(:id) }
      duplicates = ids.tally.select { |_id, count| count > 1 }.keys
      @errors << "duplicate proposal IDs: #{duplicates.join(', ')}" unless duplicates.empty?

      proposals.each do |proposal|
        id = proposal.fetch(:id)
        suffix = id.delete_prefix("proposal-")
        @errors << "invalid proposal ID '#{id}'" unless suffix.match?(ID_PATTERN)
        if proposal[:data_id] != suffix
          @errors << "#{id} must use data-proposal-id=\"#{suffix}\""
        end
        @errors << "navigation link ##{id} is missing" unless attribute_values("href").include?("##{id}")
      end
    end

    def proposal_elements
      @html.scan(/<(?:section|article)\b[^>]*>/im).filter_map do |tag|
        id = attribute_value(tag, "id")
        next unless id&.start_with?("proposal-")

        { id: id, data_id: attribute_value(tag, "data-proposal-id") }
      end
    end

    def attribute_value(fragment, name)
      match = fragment.match(/\b#{Regexp.escape(name)}\s*=\s*(["'])(.*?)\1/im)
      match && match[2]
    end

    def attribute_values(name)
      @html.scan(/\b#{Regexp.escape(name)}\s*=\s*(["'])(.*?)\1/im).map { |_quote, value| value }
    end
  end

  class CLI
    def self.run(argv, out: $stdout, err: $stderr)
      raise ArgumentError, usage unless argv.length == 1

      path = File.expand_path(argv.fetch(0))
      raise ArgumentError, "HTML file not found: #{path}" unless File.file?(path)

      Validator.new(File.read(path, encoding: "UTF-8")).validate!
      out.puts "Valid UI proposals: #{path}"
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
      "usage: validate_proposals.rb <proposals.html>"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  exit UiMockProposals::CLI.run(ARGV)
end
