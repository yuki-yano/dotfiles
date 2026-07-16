#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi/escape"
require "date"
require "digest"
require "base64"
require "erb"
require "fileutils"
require "tempfile"
require "yaml"
require_relative "../../_shared/html-artifacts/scripts/validate_html"

module BuildTechnicalExplainer
  ROOT = File.expand_path("..", __dir__)
  ASSETS = File.join(ROOT, "assets")
  STARTER_PATH = File.join(ASSETS, "starter.yaml")
  TEMPLATE_PATH = File.join(ASSETS, "report.html.erb")
  CSS_PATH = File.join(ASSETS, "report.css")
  JS_PATH = File.join(ASSETS, "report.js")

  ID_PATTERN = /\A[a-z][a-z0-9]*(?:-[a-z0-9]+)*\z/
  DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/
  KINDS = %w[research audit comparison decision implementation-report].freeze
  STATUSES = %w[draft final].freeze
  VISIBILITIES = %w[private shareable].freeze
  BLOCK_TYPES = %w[prose list table code callout checklist details chart diagram findings].freeze
  LIST_STYLES = %w[bullet number].freeze
  CALLOUT_TONES = %w[neutral info success warning critical].freeze
  CHART_KINDS = %w[line bar].freeze
  DIAGRAM_KINDS = %w[flow dependency sequence].freeze
  DIAGRAM_DIRECTIONS = %w[horizontal vertical].freeze
  ARTIFACT_RELATIONS = %w[visual-spec context implementation-plan related].freeze
  SHAREABLE_LOCAL_PATTERNS = [
    /file:\/\//i,
    %r{(?:\A|[\s"'`=(])/(?:Users|home)/[^/\s]+}i,
    %r{https?://(?:localhost|127\.0\.0\.1|0\.0\.0\.0)(?::\d+)?}i
  ].freeze

  KIND_LABELS = {
    "research" => "調査",
    "audit" => "監査",
    "comparison" => "比較",
    "decision" => "判断",
    "implementation-report" => "実装結果"
  }.freeze
  STATUS_LABELS = { "draft" => "下書き", "final" => "確定" }.freeze
  VISIBILITY_LABELS = { "private" => "非公開", "shareable" => "共有可" }.freeze

  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super(errors.join("\n"))
    end
  end

  class InputError < StandardError; end

  class Loader
    def self.load(path)
      expanded = File.expand_path(path)
      raise InputError, "YAML file not found: #{expanded}" unless File.file?(expanded)

      data = YAML.safe_load(
        File.read(expanded, encoding: "UTF-8"),
        permitted_classes: [Date],
        aliases: false
      )
      raise ValidationError, ["root: mapping is required"] unless data.is_a?(Hash)

      data
    rescue Psych::Exception => e
      raise ValidationError, ["YAML: #{e.message}"]
    end
  end

  class Validator
    Result = Data.define(:warnings)

    ROOT_KEYS = %w[version document metrics sections sources related_artifacts].freeze
    DOCUMENT_KEYS = %w[title summary kind status visibility updated audience tags].freeze
    METRIC_KEYS = %w[label value note].freeze
    SECTION_KEYS = %w[id title lead blocks].freeze
    SOURCE_KEYS = %w[id title href accessed note].freeze
    ARTIFACT_KEYS = %w[id title href relation note].freeze
    COMMON_BLOCK_KEYS = %w[type refs].freeze
    BLOCK_KEYS = {
      "prose" => %w[text],
      "list" => %w[style items],
      "table" => %w[caption columns rows],
      "code" => %w[language caption content],
      "callout" => %w[tone title text],
      "checklist" => %w[title items],
      "details" => %w[summary open blocks],
      "chart" => %w[kind title x_label y_label unit labels series],
      "diagram" => %w[kind title direction nodes edges],
      "findings" => %w[id title facets items]
    }.freeze

    def initialize(data)
      @data = data
      @errors = []
      @warnings = []
      @section_ids = []
      @source_ids = []
      @artifact_ids = []
      @finding_ids = []
      @refs = []
    end

    def validate!
      validate_root
      raise ValidationError, @errors unless @errors.empty?

      Result.new(warnings: @warnings.freeze)
    end

    private

    def validate_root
      check_keys(@data, ROOT_KEYS, "root")
      add_error("version", "must be 1") unless @data["version"] == 1

      document = expect_hash(@data["document"], "document")
      validate_document(document) if document

      metrics = expect_array(@data.fetch("metrics", []), "metrics")
      metrics.each_with_index { |metric, index| validate_metric(metric, "metrics[#{index}]") }

      artifacts = expect_array(@data.fetch("related_artifacts", []), "related_artifacts")
      artifacts.each_with_index { |artifact, index| validate_artifact(artifact, "related_artifacts[#{index}]") }
      validate_unique_ids(@artifact_ids, "related_artifacts")

      sections = expect_array(@data["sections"], "sections")
      add_error("sections", "must contain at least one section") if sections.empty?
      sections.each_with_index { |section, index| validate_section(section, "sections[#{index}]") }
      validate_unique_ids(@section_ids, "sections")
      validate_unique_values(@finding_ids, "findings", "findings ID")

      sources = expect_array(@data.fetch("sources", []), "sources")
      sources.each_with_index { |source, index| validate_source(source, "sources[#{index}]") }
      validate_unique_ids(@source_ids, "sources")
      validate_references
      validate_shareable(document) if document && document["visibility"] == "shareable"
    end

    def validate_document(document)
      check_keys(document, DOCUMENT_KEYS, "document")
      required_string(document, "title", "document", max: 160)
      required_string(document, "summary", "document", max: 1_200)
      enum(document["kind"], KINDS, "document.kind")
      enum(document["status"], STATUSES, "document.status")
      enum(document["visibility"], VISIBILITIES, "document.visibility")
      date(document["updated"], "document.updated")
      optional_string(document, "audience", "document", max: 200)

      tags = expect_array(document.fetch("tags", []), "document.tags")
      tags.each_with_index { |tag, index| string(tag, "document.tags[#{index}]", max: 60) }
      add_error("document.tags", "must contain no more than 12 items") if tags.length > 12
    end

    def validate_metric(metric, path)
      metric = expect_hash(metric, path)
      return unless metric

      check_keys(metric, METRIC_KEYS, path)
      required_string(metric, "label", path, max: 80)
      required_scalar(metric, "value", path)
      optional_string(metric, "note", path, max: 240)
    end

    def validate_section(section, path)
      section = expect_hash(section, path)
      return unless section

      check_keys(section, SECTION_KEYS, path)
      id = required_id(section, "id", path)
      @section_ids << id if id
      required_string(section, "title", path, max: 160)
      optional_string(section, "lead", path, max: 800)

      blocks = expect_array(section["blocks"], "#{path}.blocks")
      add_error("#{path}.blocks", "must contain at least one block") if blocks.empty?
      blocks.each_with_index { |block, index| validate_block(block, "#{path}.blocks[#{index}]") }
    end

    def validate_block(block, path, nested: false)
      block = expect_hash(block, path)
      return unless block

      type = block["type"]
      enum(type, BLOCK_TYPES, "#{path}.type")
      allowed_keys = COMMON_BLOCK_KEYS + BLOCK_KEYS.fetch(type, [])
      check_keys(block, allowed_keys, path)
      validate_refs(block.fetch("refs", []), "#{path}.refs")
      add_error("#{path}.type", "details cannot be nested") if nested && type == "details"
      add_error("#{path}.type", "findings cannot be nested") if nested && type == "findings"

      case type
      when "prose"
        required_string(block, "text", path, max: 20_000)
      when "list"
        enum(block.fetch("style", "bullet"), LIST_STYLES, "#{path}.style")
        items = expect_array(block["items"], "#{path}.items")
        add_error("#{path}.items", "must contain at least one item") if items.empty?
        items.each_with_index { |item, index| string(item, "#{path}.items[#{index}]", max: 2_000) }
      when "table"
        optional_string(block, "caption", path, max: 240)
        columns = expect_array(block["columns"], "#{path}.columns")
        add_error("#{path}.columns", "must contain at least one column") if columns.empty?
        add_error("#{path}.columns", "must contain no more than 12 columns") if columns.length > 12
        columns.each_with_index { |column, index| string(column, "#{path}.columns[#{index}]", max: 160) }
        rows = expect_array(block["rows"], "#{path}.rows")
        rows.each_with_index { |row, index| validate_table_row(row, columns.length, "#{path}.rows[#{index}]") }
      when "code"
        optional_string(block, "language", path, max: 40)
        optional_string(block, "caption", path, max: 240)
        required_string(block, "content", path, max: 40_000)
      when "callout"
        enum(block.fetch("tone", "neutral"), CALLOUT_TONES, "#{path}.tone")
        required_string(block, "title", path, max: 160)
        required_string(block, "text", path, max: 4_000)
      when "checklist"
        optional_string(block, "title", path, max: 160)
        items = expect_array(block["items"], "#{path}.items")
        add_error("#{path}.items", "must contain at least one item") if items.empty?
        items.each_with_index { |item, index| validate_checklist_item(item, "#{path}.items[#{index}]") }
      when "details"
        required_string(block, "summary", path, max: 240)
        boolean(block["open"], "#{path}.open") if block.key?("open")
        blocks = expect_array(block["blocks"], "#{path}.blocks")
        add_error("#{path}.blocks", "must contain at least one block") if blocks.empty?
        add_error("#{path}.blocks", "must contain no more than 12 blocks") if blocks.length > 12
        blocks.each_with_index { |child, index| validate_block(child, "#{path}.blocks[#{index}]", nested: true) }
      when "chart"
        validate_chart(block, path)
      when "diagram"
        validate_diagram(block, path)
      when "findings"
        validate_findings(block, path)
      end
    end

    def validate_artifact(artifact, path)
      artifact = expect_hash(artifact, path)
      return unless artifact

      check_keys(artifact, ARTIFACT_KEYS, path)
      id = required_id(artifact, "id", path)
      @artifact_ids << id if id
      required_string(artifact, "title", path, max: 300)
      required_string(artifact, "href", path, max: 2_000)
      enum(artifact["relation"], ARTIFACT_RELATIONS, "#{path}.relation")
      optional_string(artifact, "note", path, max: 1_000)
      href = artifact["href"]
      add_error("#{path}.href", "uses an unsupported URL scheme") if href.is_a?(String) && !valid_href?(href)
    end

    def validate_chart(block, path)
      enum(block["kind"], CHART_KINDS, "#{path}.kind")
      required_string(block, "title", path, max: 240)
      optional_string(block, "x_label", path, max: 120)
      optional_string(block, "y_label", path, max: 120)
      optional_string(block, "unit", path, max: 40)

      labels = expect_array(block["labels"], "#{path}.labels")
      add_error("#{path}.labels", "must contain at least one label") if labels.empty?
      add_error("#{path}.labels", "must contain no more than 36 labels") if labels.length > 36
      labels.each_with_index { |label, index| string(label, "#{path}.labels[#{index}]", max: 80) }
      add_error("#{path}.labels", "line chart requires at least two labels") if block["kind"] == "line" && labels.length < 2

      series = expect_array(block["series"], "#{path}.series")
      add_error("#{path}.series", "must contain at least one series") if series.empty?
      add_error("#{path}.series", "must contain no more than 6 series") if series.length > 6
      names = []
      series.each_with_index do |entry, index|
        entry_path = "#{path}.series[#{index}]"
        entry = expect_hash(entry, entry_path)
        next unless entry

        check_keys(entry, %w[name values], entry_path)
        required_string(entry, "name", entry_path, max: 120)
        names << entry["name"] if entry["name"].is_a?(String)
        values = expect_array(entry["values"], "#{entry_path}.values")
        add_error("#{entry_path}.values", "must have #{labels.length} values") unless values.length == labels.length
        values.each_with_index { |value, value_index| number(value, "#{entry_path}.values[#{value_index}]") }
      end
      validate_unique_values(names, "#{path}.series", "series name")
    end

    def validate_diagram(block, path)
      enum(block["kind"], DIAGRAM_KINDS, "#{path}.kind")
      required_string(block, "title", path, max: 240)
      if block["kind"] == "sequence"
        add_error("#{path}.direction", "is not used by sequence diagrams") if block.key?("direction")
      else
        enum(block.fetch("direction", "horizontal"), DIAGRAM_DIRECTIONS, "#{path}.direction")
      end

      nodes = expect_array(block["nodes"], "#{path}.nodes")
      add_error("#{path}.nodes", "must contain 2 to 8 nodes") unless nodes.length.between?(2, 8)
      node_ids = []
      nodes.each_with_index do |node, index|
        node_path = "#{path}.nodes[#{index}]"
        node = expect_hash(node, node_path)
        next unless node

        check_keys(node, %w[id label tone], node_path)
        id = required_id(node, "id", node_path)
        node_ids << id if id
        required_string(node, "label", node_path, max: 60)
        enum(node.fetch("tone", "neutral"), CALLOUT_TONES, "#{node_path}.tone")
      end
      validate_unique_values(node_ids, "#{path}.nodes", "node ID")

      edges = expect_array(block["edges"], "#{path}.edges")
      add_error("#{path}.edges", "must contain 1 to 16 edges") unless edges.length.between?(1, 16)
      edges.each_with_index do |edge, index|
        edge_path = "#{path}.edges[#{index}]"
        edge = expect_hash(edge, edge_path)
        next unless edge

        check_keys(edge, %w[from to label], edge_path)
        from = required_id(edge, "from", edge_path)
        to = required_id(edge, "to", edge_path)
        optional_string(edge, "label", edge_path, max: 80)
        add_error("#{edge_path}.from", "references unknown node '#{from}'") if from && !node_ids.include?(from)
        add_error("#{edge_path}.to", "references unknown node '#{to}'") if to && !node_ids.include?(to)
        add_error(edge_path, "self-referencing edges are not supported") if from && from == to
      end
    end

    def validate_findings(block, path)
      id = required_id(block, "id", path)
      @finding_ids << id if id
      optional_string(block, "title", path, max: 240)
      facets = expect_array(block["facets"], "#{path}.facets")
      add_error("#{path}.facets", "must contain 1 to 4 facets") unless facets.length.between?(1, 4)
      facet_values = {}
      facets.each_with_index do |facet, index|
        facet_path = "#{path}.facets[#{index}]"
        facet = expect_hash(facet, facet_path)
        next unless facet

        check_keys(facet, %w[id label values], facet_path)
        id = required_id(facet, "id", facet_path)
        required_string(facet, "label", facet_path, max: 80)
        values = expect_array(facet["values"], "#{facet_path}.values")
        add_error("#{facet_path}.values", "must contain 1 to 8 values") unless values.length.between?(1, 8)
        value_ids = []
        values.each_with_index do |value, value_index|
          value_path = "#{facet_path}.values[#{value_index}]"
          value = expect_hash(value, value_path)
          next unless value

          check_keys(value, %w[id label], value_path)
          value_id = required_id(value, "id", value_path)
          value_ids << value_id if value_id
          required_string(value, "label", value_path, max: 80)
        end
        validate_unique_values(value_ids, "#{facet_path}.values", "facet value ID")
        facet_values[id] = value_ids if id
      end
      validate_unique_values(facet_values.keys, "#{path}.facets", "facet ID")

      items = expect_array(block["items"], "#{path}.items")
      add_error("#{path}.items", "must contain 1 to 100 items") unless items.length.between?(1, 100)
      item_ids = []
      items.each_with_index do |item, index|
        item_path = "#{path}.items[#{index}]"
        item = expect_hash(item, item_path)
        next unless item

        check_keys(item, %w[id title summary facets details refs], item_path)
        id = required_id(item, "id", item_path)
        item_ids << id if id
        required_string(item, "title", item_path, max: 240)
        required_string(item, "summary", item_path, max: 2_000)
        validate_refs(item.fetch("refs", []), "#{item_path}.refs")

        assignments = expect_hash(item["facets"], "#{item_path}.facets") || {}
        check_keys(assignments, facet_values.keys, "#{item_path}.facets")
        missing = facet_values.keys - assignments.keys
        add_error("#{item_path}.facets", "missing facets: #{missing.join(', ')}") unless missing.empty?
        assignments.each do |facet_id, value_id|
          unless value_id.is_a?(String) && facet_values.fetch(facet_id, []).include?(value_id)
            add_error("#{item_path}.facets.#{facet_id}", "uses an unknown facet value")
          end
        end

        details = expect_array(item.fetch("details", []), "#{item_path}.details")
        add_error("#{item_path}.details", "must contain no more than 8 details") if details.length > 8
        details.each_with_index do |detail, detail_index|
          detail_path = "#{item_path}.details[#{detail_index}]"
          detail = expect_hash(detail, detail_path)
          next unless detail

          check_keys(detail, %w[label text], detail_path)
          required_string(detail, "label", detail_path, max: 120)
          required_string(detail, "text", detail_path, max: 4_000)
        end
      end
      validate_unique_values(item_ids, "#{path}.items", "finding ID")
    end

    def validate_table_row(row, column_count, path)
      row = expect_array(row, path)
      add_error(path, "must have #{column_count} cells") unless row.length == column_count
      row.each_with_index do |cell, index|
        next if scalar?(cell) || cell.nil?

        add_error("#{path}[#{index}]", "must be a scalar or null")
      end
    end

    def validate_checklist_item(item, path)
      item = expect_hash(item, path)
      return unless item

      check_keys(item, %w[text checked], path)
      required_string(item, "text", path, max: 2_000)
      add_error("#{path}.checked", "must be true or false") unless [true, false].include?(item["checked"])
    end

    def validate_source(source, path)
      source = expect_hash(source, path)
      return unless source

      check_keys(source, SOURCE_KEYS, path)
      id = required_id(source, "id", path)
      @source_ids << id if id
      required_string(source, "title", path, max: 300)
      optional_string(source, "note", path, max: 1_000)
      date(source["accessed"], "#{path}.accessed") if source.key?("accessed")

      return unless source.key?("href")

      href = source["href"]
      string(href, "#{path}.href", max: 2_000)
      add_error("#{path}.href", "uses an unsupported URL scheme") if href.is_a?(String) && !valid_href?(href)
    end

    def validate_refs(refs, path)
      refs = expect_array(refs, path)
      refs.each_with_index do |ref, index|
        if id?(ref)
          @refs << [ref, "#{path}[#{index}]"]
        else
          add_error("#{path}[#{index}]", "must be a lowercase source ID")
        end
      end
    end

    def validate_references
      known = @source_ids.compact.uniq
      @refs.each do |ref, path|
        add_error(path, "references unknown source '#{ref}'") unless known.include?(ref)
      end

      unused = known - @refs.map(&:first).uniq
      @warnings << "unused sources: #{unused.join(', ')}" unless unused.empty?
    end

    def validate_shareable(_document)
      leaks = []
      walk_strings(@data) do |value, path|
        next unless SHAREABLE_LOCAL_PATTERNS.any? { |pattern| value.match?(pattern) }

        leaks << path
      end
      return if leaks.empty?

      add_error(
        "document.visibility",
        "shareable content contains local information at: #{leaks.uniq.join(', ')}"
      )
    end

    def walk_strings(value, path = "root", &block)
      case value
      when Hash
        value.each { |key, child| walk_strings(child, "#{path}.#{key}", &block) }
      when Array
        value.each_with_index { |child, index| walk_strings(child, "#{path}[#{index}]", &block) }
      when String
        yield value, path
      end
    end

    def valid_href?(href)
      return false if href.empty? || href != href.strip || href.match?(/[\u0000-\u001f]/)
      return true if href.start_with?("https://", "http://", "file://", "/", "./", "../", "#")

      !href.match?(/\A[a-z][a-z0-9+.-]*:/i)
    end

    def validate_unique_ids(ids, path)
      ids.compact.tally.each do |id, count|
        add_error(path, "duplicate ID '#{id}'") if count > 1
      end
    end

    def check_keys(hash, allowed, path)
      unknown = hash.keys.reject { |key| key.is_a?(String) && allowed.include?(key) }
      add_error(path, "unknown fields: #{unknown.map(&:inspect).join(', ')}") unless unknown.empty?
    end

    def required_string(hash, key, path, max:)
      if !hash.key?(key)
        add_error("#{path}.#{key}", "is required")
      else
        string(hash[key], "#{path}.#{key}", max: max)
      end
    end

    def optional_string(hash, key, path, max:)
      string(hash[key], "#{path}.#{key}", max: max) if hash.key?(key)
    end

    def required_scalar(hash, key, path)
      if !hash.key?(key)
        add_error("#{path}.#{key}", "is required")
      elsif !scalar?(hash[key])
        add_error("#{path}.#{key}", "must be a scalar")
      end
    end

    def required_id(hash, key, path)
      unless hash.key?(key)
        add_error("#{path}.#{key}", "is required")
        return nil
      end

      value = hash[key]
      return value if id?(value)

      add_error("#{path}.#{key}", "must match #{ID_PATTERN.inspect}")
      nil
    end

    def id?(value)
      value.is_a?(String) && value.match?(ID_PATTERN)
    end

    def string(value, path, max:)
      unless value.is_a?(String)
        add_error(path, "must be a string")
        return
      end
      add_error(path, "must not be empty") if value.strip.empty?
      add_error(path, "must be at most #{max} characters") if value.length > max
    end

    def enum(value, allowed, path)
      add_error(path, "must be one of: #{allowed.join(', ')}") unless allowed.include?(value)
    end

    def date(value, path)
      text = value.is_a?(Date) ? value.iso8601 : value
      unless text.is_a?(String) && text.match?(DATE_PATTERN)
        add_error(path, "must use YYYY-MM-DD")
        return
      end
      Date.iso8601(text)
    rescue Date::Error
      add_error(path, "must be a real calendar date")
    end

    def expect_hash(value, path)
      return value if value.is_a?(Hash)

      add_error(path, "must be a mapping")
      nil
    end

    def expect_array(value, path)
      return value if value.is_a?(Array)

      add_error(path, "must be a list")
      []
    end

    def scalar?(value)
      value.is_a?(String) || value.is_a?(Numeric) || value == true || value == false
    end

    def boolean(value, path)
      add_error(path, "must be true or false") unless [true, false].include?(value)
    end

    def number(value, path)
      valid = value.is_a?(Numeric) && (!value.respond_to?(:finite?) || value.finite?)
      add_error(path, "must be a finite number") unless valid
    end

    def validate_unique_values(values, path, label)
      values.compact.tally.each do |value, count|
        add_error(path, "duplicate #{label} '#{value}'") if count > 1
      end
    end

    def add_error(path, message)
      @errors << "#{path}: #{message}"
    end
  end

  class Renderer
    def initialize(data)
      @data = data
      @document = data.fetch("document")
      @sources = data.fetch("sources", [])
      @artifacts = data.fetch("related_artifacts", [])
      @source_by_id = @sources.to_h { |source| [source.fetch("id"), source] }
      @block_counter = 0
    end

    def render
      @css = File.read(CSS_PATH, encoding: "UTF-8").rstrip
      @script = interactive? ? File.read(JS_PATH, encoding: "UTF-8").rstrip : ""
      @csp = render_csp
      @title = h(@document.fetch("title"))
      @summary = h(@document.fetch("summary"))
      @meta_html = render_meta
      @tags_html = render_tags
      @metrics_html = render_metrics
      @related_artifacts_html = render_related_artifacts
      @toc_html = render_toc
      @sections_html = render_sections
      @sources_html = render_sources
      @script_html = @script.empty? ? "" : %(<script>#{@script}</script>)
      @footer_capability = @script.empty? ? "外部asset・JavaScriptなし" : "外部assetなし・固定filterのみ"

      ERB.new(File.read(TEMPLATE_PATH, encoding: "UTF-8"), trim_mode: "-").result(binding)
    end

    private

    def h(value)
      CGI.escapeHTML(value.to_s)
    end

    def interactive?
      @data.fetch("sections").any? do |section|
        section.fetch("blocks").any? { |block| block["type"] == "findings" }
      end
    end

    def render_csp
      script_policy = if @script.empty?
                        "'none'"
                      else
                        encoded = Base64.strict_encode64(Digest::SHA256.digest(@script))
                        "'sha256-#{encoded}'"
                      end
      "default-src 'none'; style-src 'unsafe-inline'; img-src 'none'; font-src 'none'; " \
        "script-src #{script_policy}; connect-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'"
    end

    def render_meta
      items = [
        ["kind", KIND_LABELS.fetch(@document.fetch("kind"))],
        ["status", STATUS_LABELS.fetch(@document.fetch("status"))],
        ["updated", "更新 #{date_text(@document.fetch('updated'))}"],
        ["visibility", VISIBILITY_LABELS.fetch(@document.fetch("visibility"))]
      ]
      items << ["audience", "対象 #{@document['audience']}"] if @document["audience"]
      items.map { |klass, text| %(<span class="meta-item #{h(klass)}">#{h(text)}</span>) }.join
    end

    def render_tags
      tags = @document.fetch("tags", [])
      return "" if tags.empty?

      %(<div class="tag-list" aria-label="タグ">#{tags.map { |tag| %(<span class="tag">#{h(tag)}</span>) }.join}</div>)
    end

    def render_metrics
      metrics = @data.fetch("metrics", [])
      return "" if metrics.empty?

      cards = metrics.map do |metric|
        note = metric["note"] ? %(<span class="metric-note">#{h(metric['note'])}</span>) : ""
        <<~HTML
          <div class="metric">
            <span class="metric-label">#{h(metric.fetch('label'))}</span>
            <strong class="metric-value">#{h(metric.fetch('value'))}</strong>
            #{note}
          </div>
        HTML
      end.join
      <<~HTML
        <section class="metrics-panel" aria-labelledby="metrics-title">
          <h2 id="metrics-title">概要指標</h2>
          <div class="metrics-grid">#{cards}</div>
        </section>
      HTML
    end

    def render_related_artifacts
      return "" if @artifacts.empty?

      relation_labels = {
        "visual-spec" => "視覚仕様",
        "context" => "前提資料",
        "implementation-plan" => "実装計画",
        "related" => "関連資料"
      }
      cards = @artifacts.map do |artifact|
        external = artifact.fetch("href").start_with?("https://", "http://")
        attrs = external ? %( target="_blank" rel="noopener noreferrer") : ""
        note = artifact["note"] ? %(<span class="artifact-note">#{h(artifact['note'])}</span>) : ""
        <<~HTML
          <li id="artifact-#{h(artifact.fetch('id'))}">
            <span class="artifact-relation">#{h(relation_labels.fetch(artifact.fetch('relation')))}</span>
            <a href="#{h(artifact.fetch('href'))}"#{attrs}>#{h(artifact.fetch('title'))}</a>
            #{note}
          </li>
        HTML
      end.join
      <<~HTML
        <section class="related-artifacts" id="related-artifacts" aria-labelledby="related-artifacts-title">
          <h2 id="related-artifacts-title">関連成果物</h2>
          <ul>#{cards}</ul>
        </section>
      HTML
    end

    def render_toc
      items = @data.fetch("sections").map do |section|
        %(<li><a href="#section-#{h(section.fetch('id'))}">#{h(section.fetch('title'))}</a></li>)
      end
      items << %(<li><a href="#related-artifacts">関連成果物</a></li>) unless @artifacts.empty?
      items << %(<li><a href="#sources">出典</a></li>) unless @sources.empty?
      items.join
    end

    def render_sections
      @data.fetch("sections").map do |section|
        id = section.fetch("id")
        lead = section["lead"] ? %(<p class="section-lead">#{h(section['lead'])}</p>) : ""
        blocks = section.fetch("blocks").map { |block| render_block(block) }.join
        <<~HTML
          <section class="report-section" id="section-#{h(id)}" aria-labelledby="section-#{h(id)}-title">
            <span class="section-id">#{h(id)}</span>
            <h2 id="section-#{h(id)}-title">#{h(section.fetch('title'))}</h2>
            #{lead}
            #{blocks}
          </section>
        HTML
      end.join
    end

    def render_block(block)
      @block_counter += 1
      block_id = "block-#{@block_counter}"
      body = case block.fetch("type")
             when "prose" then render_prose(block)
             when "list" then render_list(block)
             when "table" then render_table(block)
             when "code" then render_code(block)
             when "callout" then render_callout(block)
             when "checklist" then render_checklist(block)
             when "details" then render_details(block)
             when "chart" then render_chart(block, block_id)
             when "diagram" then render_diagram(block, block_id)
             when "findings" then render_findings(block)
             end
      %(<div class="content-block #{h(block.fetch('type'))}">#{body}#{render_refs(block.fetch('refs', []))}</div>)
    end

    def render_prose(block)
      render_paragraphs(block.fetch("text"))
    end

    def render_paragraphs(text)
      text.split(/\n{2,}/).map do |paragraph|
        %(<p>#{h(paragraph.strip).gsub("\n", "<br>\n")}</p>)
      end.join
    end

    def render_list(block)
      tag = block.fetch("style", "bullet") == "number" ? "ol" : "ul"
      items = block.fetch("items").map { |item| %(<li>#{h(item)}</li>) }.join
      %(<#{tag} class="content-list">#{items}</#{tag}>)
    end

    def render_table(block)
      columns = block.fetch("columns")
      caption = block["caption"] ? %(<caption>#{h(block['caption'])}</caption>) : ""
      head = columns.map { |column| %(<th scope="col">#{h(column)}</th>) }.join
      rows = block.fetch("rows").map do |row|
        cells = row.each_with_index.map do |cell, index|
          %(<td data-label="#{h(columns[index])}">#{h(cell)}</td>)
        end.join
        %(<tr>#{cells}</tr>)
      end.join
      <<~HTML
        <div class="table-wrap">
          <table>
            #{caption}
            <thead><tr>#{head}</tr></thead>
            <tbody>#{rows}</tbody>
          </table>
        </div>
      HTML
    end

    def render_code(block)
      labels = [block["caption"], block["language"]].compact
      caption = labels.empty? ? "" : %(<div class="code-caption">#{h(labels.join(' · '))}</div>)
      language = block["language"] ? %( data-language="#{h(block['language'])}") : ""
      %(#{caption}<pre><code#{language}>#{h(block.fetch('content'))}</code></pre>)
    end

    def render_callout(block)
      tone = block.fetch("tone", "neutral")
      <<~HTML
        <aside class="callout #{h(tone)}">
          <p class="callout-title">#{h(block.fetch('title'))}</p>
          #{render_paragraphs(block.fetch('text'))}
        </aside>
      HTML
    end

    def render_checklist(block)
      title = block["title"] ? %(<div class="checklist-title">#{h(block['title'])}</div>) : ""
      items = block.fetch("items").map do |item|
        checked = item.fetch("checked")
        klass = checked ? "checked" : "unchecked"
        glyph = checked ? "✓" : "□"
        %(<li class="#{klass}"><span class="checkmark" aria-hidden="true">#{glyph}</span><span>#{h(item.fetch('text'))}</span></li>)
      end.join
      %(#{title}<ul class="checklist">#{items}</ul>)
    end

    def render_details(block)
      open = block.fetch("open", false) ? " open" : ""
      children = block.fetch("blocks").map { |child| render_block(child) }.join
      <<~HTML
        <details class="disclosure"#{open}>
          <summary>#{h(block.fetch('summary'))}</summary>
          <div class="disclosure-content">#{children}</div>
        </details>
      HTML
    end

    def render_findings(block)
      findings_id = block.fetch("id")
      title = block["title"] ? %(<h3>#{h(block['title'])}</h3>) : ""
      facets = block.fetch("facets")
      facet_labels = facets.to_h { |facet| [facet.fetch("id"), facet.fetch("label")] }
      facet_value_labels = facets.to_h do |facet|
        [facet.fetch("id"), facet.fetch("values").to_h { |value| [value.fetch("id"), value.fetch("label")] }]
      end
      controls = facets.map do |facet|
        facet_id = facet.fetch("id")
        options = facet.fetch("values").map do |value|
          %(<option value="#{h(value.fetch('id'))}">#{h(value.fetch('label'))}</option>)
        end.join
        <<~HTML
          <label for="findings-#{h(findings_id)}-facet-#{h(facet_id)}">
            <span>#{h(facet.fetch('label'))}</span>
            <select id="findings-#{h(findings_id)}-facet-#{h(facet_id)}" data-facet-select="#{h(facet_id)}">
              <option value="">すべて</option>
              #{options}
            </select>
          </label>
        HTML
      end.join
      items = block.fetch("items").map do |item|
        attributes = item.fetch("facets").map do |facet_id, value_id|
          %( data-facet-#{h(facet_id)}="#{h(value_id)}")
        end.join
        badges = item.fetch("facets").map do |facet_id, value_id|
          label = "#{facet_labels.fetch(facet_id)}: #{facet_value_labels.fetch(facet_id).fetch(value_id)}"
          %(<span class="finding-badge">#{h(label)}</span>)
        end.join
        details = item.fetch("details", []).map do |detail|
          %(<div><dt>#{h(detail.fetch('label'))}</dt><dd>#{render_paragraphs(detail.fetch('text'))}</dd></div>)
        end.join
        details_html = details.empty? ? "" : %(<dl class="finding-details">#{details}</dl>)
        <<~HTML
          <article id="finding-#{h(findings_id)}-#{h(item.fetch('id'))}" class="finding-card" data-finding-item#{attributes}>
            <div class="finding-badges">#{badges}</div>
            <h4>#{h(item.fetch('title'))}</h4>
            #{render_paragraphs(item.fetch('summary'))}
            #{details_html}
            #{render_refs(item.fetch('refs', []))}
          </article>
        HTML
      end.join
      <<~HTML
        <section id="findings-#{h(findings_id)}" class="findings-panel" data-findings>
          #{title}
          <div class="finding-filterbar" aria-label="指摘の絞り込み">
            #{controls}
            <button type="button" data-filter-reset>リセット</button>
            <span class="finding-count" data-filter-count role="status" aria-live="polite"></span>
          </div>
          <div class="finding-list">#{items}</div>
        </section>
      HTML
    end

    def render_chart(block, block_id)
      labels = block.fetch("labels")
      series = block.fetch("series")
      values = series.flat_map { |entry| entry.fetch("values") }.map(&:to_f)
      minimum = values.min
      maximum = values.max
      if block.fetch("kind") == "bar"
        minimum = [minimum, 0.0].min
        maximum = [maximum, 0.0].max
      end
      if minimum == maximum
        padding = minimum.zero? ? 1.0 : minimum.abs * 0.1
        minimum -= padding
        maximum += padding
      elsif block.fetch("kind") == "line"
        padding = (maximum - minimum) * 0.08
        minimum -= padding
        maximum += padding
      end

      width = 720.0
      height = 360.0
      left = 70.0
      right = 690.0
      top = 44.0
      bottom = 286.0
      plot_width = right - left
      plot_height = bottom - top
      scale_y = lambda { |value| bottom - ((value.to_f - minimum) / (maximum - minimum) * plot_height) }
      x_at = lambda do |index|
        labels.length == 1 ? left + (plot_width / 2.0) : left + (index.to_f / (labels.length - 1) * plot_width)
      end

      y_grid = (0..4).map do |index|
        value = maximum - ((maximum - minimum) * index / 4.0)
        y = top + (plot_height * index / 4.0)
        <<~SVG
          <line class="chart-grid" x1="#{left}" y1="#{round_svg(y)}" x2="#{right}" y2="#{round_svg(y)}" />
          <text class="chart-tick" x="#{left - 10}" y="#{round_svg(y + 4)}" text-anchor="end">#{h(format_number(value, block['unit']))}</text>
        SVG
      end.join
      label_step = [(labels.length / 8.0).ceil, 1].max
      label_indexes = labels.each_index.select { |index| (index % label_step).zero? }
      unless label_indexes.last == labels.length - 1
        label_indexes.pop if label_indexes.length > 1 && (labels.length - 1 - label_indexes.last) < label_step
        label_indexes << labels.length - 1
      end
      base_tick_spacing = labels.length == 1 ? plot_width : plot_width / (labels.length - 1)
      minimum_tick_gap = label_indexes.each_cons(2).map { |left_index, right_index| right_index - left_index }.min || 1
      tick_label_width = [base_tick_spacing * minimum_tick_gap * 0.8, 96.0].min
      x_labels = label_indexes.map do |index|
        label = labels.fetch(index)
        %(<text class="chart-tick" x="#{round_svg(x_at.call(index))}" y="#{bottom + 24}" text-anchor="middle">#{h(fit_svg_label(label, tick_label_width))}</text>)
      end.join

      marks = if block.fetch("kind") == "line"
                render_line_chart_marks(series, x_at, scale_y)
              else
                render_bar_chart_marks(series, labels.length, left, plot_width, scale_y, bottom, minimum, maximum)
              end
      title_id = "#{block_id}-chart-title"
      x_axis = block["x_label"] ? %(<text class="chart-axis-label" x="#{width / 2}" y="#{height - 12}" text-anchor="middle">#{h(block['x_label'])}</text>) : ""
      y_axis = block["y_label"] ? %(<text class="chart-axis-label" transform="translate(16 #{height / 2}) rotate(-90)" text-anchor="middle">#{h(block['y_label'])}</text>) : ""
      legend = series.each_with_index.map do |entry, index|
        %(<li><span class="series-swatch series-#{index}"></span>#{h(entry.fetch('name'))}</li>)
      end.join
      data_table = render_table(
        "columns" => [block.fetch("x_label", "項目")] + series.map { |entry| entry.fetch("name") },
        "rows" => labels.each_with_index.map do |label, index|
          [label] + series.map { |entry| format_number(entry.fetch("values")[index], block["unit"]) }
        end
      )
      <<~HTML
        <figure class="chart-figure">
          <figcaption id="#{h(title_id)}">#{h(block.fetch('title'))}</figcaption>
          <svg class="chart-svg" viewBox="0 0 #{width.to_i} #{height.to_i}" role="img" aria-labelledby="#{h(title_id)}">
            #{y_grid}
            <line class="chart-axis" x1="#{left}" y1="#{bottom}" x2="#{right}" y2="#{bottom}" />
            #{x_labels}
            #{marks}
            #{x_axis}
            #{y_axis}
          </svg>
          <ul class="chart-legend" aria-label="系列">#{legend}</ul>
          <details class="visual-data"><summary>グラフのデータ表</summary>#{data_table}</details>
        </figure>
      HTML
    end

    def render_line_chart_marks(series, x_at, scale_y)
      series.each_with_index.map do |entry, series_index|
        points = entry.fetch("values").each_with_index.map do |value, index|
          "#{round_svg(x_at.call(index))},#{round_svg(scale_y.call(value))}"
        end.join(" ")
        circles = entry.fetch("values").each_with_index.map do |value, index|
          %(<circle class="chart-point series-#{series_index}" cx="#{round_svg(x_at.call(index))}" cy="#{round_svg(scale_y.call(value))}" r="3.2" />)
        end.join
        %(<polyline class="chart-line series-#{series_index}" points="#{points}" />#{circles})
      end.join
    end

    def render_bar_chart_marks(series, label_count, left, plot_width, scale_y, bottom, minimum, maximum)
      group_width = plot_width / label_count
      usable_width = group_width * 0.72
      bar_width = usable_width / series.length
      zero = [[0.0, minimum].max, maximum].min
      zero_y = scale_y.call(zero)
      series.each_with_index.map do |entry, series_index|
        entry.fetch("values").each_with_index.map do |value, index|
          value_y = scale_y.call(value)
          x = left + (group_width * index) + ((group_width - usable_width) / 2.0) + (bar_width * series_index)
          y = [value_y, zero_y].min
          height = [(value_y - zero_y).abs, 1.0].max
          %(<rect class="chart-bar series-#{series_index}" x="#{round_svg(x)}" y="#{round_svg(y)}" width="#{round_svg([bar_width - 2.0, 1.0].max)}" height="#{round_svg(height)}" />)
        end.join
      end.join
    end

    def render_diagram(block, block_id)
      block.fetch("kind") == "sequence" ? render_sequence_diagram(block, block_id) : render_flow_diagram(block, block_id)
    end

    def render_flow_diagram(block, block_id)
      nodes = block.fetch("nodes")
      edges = block.fetch("edges")
      direction = block.fetch("direction", "horizontal")
      width = 720.0
      if direction == "vertical"
        height = [180.0 + ((nodes.length - 1) * 92.0), 260.0].max
        positions = nodes.each_with_index.to_h { |node, index| [node.fetch("id"), [360.0, 60.0 + (index * 92.0)]] }
        node_width = 190.0
      else
        height = 230.0
        spacing = (width - 140.0) / (nodes.length - 1)
        positions = nodes.each_with_index.to_h { |node, index| [node.fetch("id"), [70.0 + (index * spacing), 95.0]] }
        node_width = [108.0, spacing - 8.0].min
      end
      node_height = 56.0
      marker_id = "#{block_id}-arrow"
      edge_svg = edges.map do |edge|
        from_x, from_y = positions.fetch(edge.fetch("from"))
        to_x, to_y = positions.fetch(edge.fetch("to"))
        if direction == "vertical"
          sign = to_y > from_y ? 1 : -1
          x1 = from_x
          y1 = from_y + (sign * node_height / 2.0)
          x2 = to_x
          y2 = to_y - (sign * node_height / 2.0)
        else
          sign = to_x > from_x ? 1 : -1
          x1 = from_x + (sign * node_width / 2.0)
          y1 = from_y
          x2 = to_x - (sign * node_width / 2.0)
          y2 = to_y
        end
        edge_label_width = direction == "vertical" ? node_width - 12.0 : [(to_x - from_x).abs - 16.0, 40.0].max
        label = edge["label"] ? %(<text class="diagram-edge-label" x="#{round_svg((x1 + x2) / 2.0)}" y="#{round_svg(((y1 + y2) / 2.0) - 8)}" text-anchor="middle">#{h(fit_svg_label(edge['label'], edge_label_width))}</text>) : ""
        %(<line class="diagram-edge" x1="#{round_svg(x1)}" y1="#{round_svg(y1)}" x2="#{round_svg(x2)}" y2="#{round_svg(y2)}" marker-end="url(##{h(marker_id)})" />#{label})
      end.join
      node_svg = nodes.map do |node|
        x, y = positions.fetch(node.fetch("id"))
        <<~SVG
          <g class="diagram-node #{h(node.fetch('tone', 'neutral'))}">
            <rect x="#{round_svg(x - node_width / 2.0)}" y="#{round_svg(y - node_height / 2.0)}" width="#{round_svg(node_width)}" height="#{node_height}" rx="6" />
            <text x="#{round_svg(x)}" y="#{round_svg(y + 5)}" text-anchor="middle">#{h(fit_svg_label(node.fetch('label'), node_width - 12.0))}</text>
          </g>
        SVG
      end.join
      render_diagram_figure(block, block_id, width, height, marker_id, edge_svg + node_svg)
    end

    def render_sequence_diagram(block, block_id)
      nodes = block.fetch("nodes")
      edges = block.fetch("edges")
      width = 720.0
      height = 125.0 + (edges.length * 52.0)
      spacing = (width - 120.0) / (nodes.length - 1)
      positions = nodes.each_with_index.to_h { |node, index| [node.fetch("id"), 60.0 + (index * spacing)] }
      marker_id = "#{block_id}-arrow"
      participants = nodes.map do |node|
        x = positions.fetch(node.fetch("id"))
        <<~SVG
          <g class="diagram-node #{h(node.fetch('tone', 'neutral'))}">
            <rect x="#{round_svg(x - 52)}" y="18" width="104" height="42" rx="6" />
            <text x="#{round_svg(x)}" y="44" text-anchor="middle">#{h(fit_svg_label(node.fetch('label'), 92.0))}</text>
          </g>
          <line class="diagram-lifeline" x1="#{round_svg(x)}" y1="60" x2="#{round_svg(x)}" y2="#{round_svg(height - 20)}" />
        SVG
      end.join
      messages = edges.each_with_index.map do |edge, index|
        from_x = positions.fetch(edge.fetch("from"))
        to_x = positions.fetch(edge.fetch("to"))
        sign = to_x > from_x ? 1 : -1
        y = 92.0 + (index * 52.0)
        label_width = [(to_x - from_x).abs - 16.0, 40.0].max
        label = edge["label"] ? h(fit_svg_label(edge["label"], label_width)) : ""
        <<~SVG
          <text class="diagram-edge-label" x="#{round_svg((from_x + to_x) / 2.0)}" y="#{round_svg(y - 8)}" text-anchor="middle">#{label}</text>
          <line class="diagram-edge" x1="#{round_svg(from_x + sign * 4)}" y1="#{round_svg(y)}" x2="#{round_svg(to_x - sign * 6)}" y2="#{round_svg(y)}" marker-end="url(##{h(marker_id)})" />
        SVG
      end.join
      render_diagram_figure(block, block_id, width, height, marker_id, participants + messages)
    end

    def render_diagram_figure(block, block_id, width, height, marker_id, content)
      title_id = "#{block_id}-diagram-title"
      node_lookup = block.fetch("nodes").to_h { |node| [node.fetch("id"), node.fetch("label")] }
      relations = block.fetch("edges").map do |edge|
        label = edge["label"] ? " — #{edge['label']}" : ""
        %(<li>#{h(node_lookup.fetch(edge.fetch('from')))} → #{h(node_lookup.fetch(edge.fetch('to')))}#{h(label)}</li>)
      end.join
      <<~HTML
        <figure class="diagram-figure">
          <figcaption id="#{h(title_id)}">#{h(block.fetch('title'))}</figcaption>
          <svg class="diagram-svg" viewBox="0 0 #{width.to_i} #{height.to_i}" role="img" aria-labelledby="#{h(title_id)}">
            <defs><marker id="#{h(marker_id)}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z" /></marker></defs>
            #{content}
          </svg>
          <details class="visual-data"><summary>図の関係をテキストで確認</summary><ul class="content-list">#{relations}</ul></details>
        </figure>
      HTML
    end

    def round_svg(value)
      format("%.2f", value.to_f).sub(/\.00\z/, "")
    end

    def fit_svg_label(value, max_width)
      text = value.to_s
      return text if svg_text_width(text) <= max_width

      budget = [max_width.to_f - svg_character_width("…"), 0.0].max
      used = 0.0
      fitted = +""
      text.each_char do |character|
        character_width = svg_character_width(character)
        break if used + character_width > budget

        fitted << character
        used += character_width
      end
      "#{fitted}…"
    end

    def svg_text_width(text)
      text.each_char.sum { |character| svg_character_width(character) }
    end

    def svg_character_width(character)
      character.ascii_only? ? 6.5 : 12.0
    end

    def format_number(value, unit = nil)
      number = value.to_f
      text = if (number - number.round).abs < 0.000_001
               number.round.to_s
             else
               format("%.2f", number).sub(/0+\z/, "").sub(/\.\z/, "")
             end
      unit ? "#{text}#{unit}" : text
    end

    def render_refs(refs)
      return "" if refs.empty?

      links = refs.map do |ref|
        source = @source_by_id.fetch(ref)
        %(<a class="source-ref" href="#source-#{h(ref)}" title="#{h(source.fetch('title'))}">[#{h(ref)}]</a>)
      end.join
      %(<div class="source-refs" aria-label="参照">#{links}</div>)
    end

    def render_sources
      return "" if @sources.empty?

      items = @sources.map do |source|
        title = source["href"] ? source_link(source) : %(<span class="source-title">#{h(source.fetch('title'))}</span>)
        accessed = source["accessed"] ? %(<span class="source-accessed">参照 #{h(date_text(source['accessed']))}</span>) : ""
        note = source["note"] ? %(<span class="source-note">#{h(source['note'])}</span>) : ""
        <<~HTML
          <li id="source-#{h(source.fetch('id'))}">
            <span class="source-key">[#{h(source.fetch('id'))}]</span>
            <div>#{title}#{accessed}#{note}</div>
          </li>
        HTML
      end.join
      <<~HTML
        <section class="sources-section" id="sources" aria-labelledby="sources-title">
          <span class="section-id">evidence</span>
          <h2 id="sources-title">出典</h2>
          <ol class="source-list">#{items}</ol>
        </section>
      HTML
    end

    def source_link(source)
      href = source.fetch("href")
      external = href.start_with?("https://", "http://")
      attrs = external ? %( target="_blank" rel="noopener noreferrer") : ""
      %(<a class="source-title" href="#{h(href)}"#{attrs}>#{h(source.fetch('title'))}</a>)
    end

    def date_text(value)
      value.is_a?(Date) ? value.iso8601 : value.to_s
    end
  end

  class StaticVerifier
    def self.verify!(html)
      HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
    rescue HtmlArtifacts::ValidationError => e
      raise ValidationError, e.errors.map { |error| "HTML: #{error}" }
    end
  end

  class CLI
    def self.run(argv, out: $stdout, err: $stderr)
      command = argv.shift
      case command
      when "init"
        require_arity!(argv, 1, "init <explainer.yaml>")
        init_file(argv.fetch(0), out: out)
      when "validate"
        require_arity!(argv, 1, "validate <explainer.yaml>")
        validate_file(argv.fetch(0), out: out)
      when "render"
        require_arity!(argv, 2, "render <explainer.yaml> <index.html>")
        render_file(argv.fetch(0), argv.fetch(1), out: out)
      when "help", "--help", "-h", nil
        out.puts usage
      else
        raise InputError, "unknown command '#{command}'\n#{usage}"
      end
      0
    rescue ValidationError => e
      err.puts "Validation failed:"
      e.errors.each { |error| err.puts "- #{error}" }
      2
    rescue InputError, Errno::EACCES, Errno::EISDIR => e
      err.puts "Error: #{e.message}"
      2
    end

    def self.init_file(path, out: $stdout)
      destination = File.expand_path(path)
      raise InputError, "refusing to overwrite existing file: #{destination}" if File.exist?(destination)

      FileUtils.mkdir_p(File.dirname(destination))
      starter = File.read(STARTER_PATH, encoding: "UTF-8").sub("__DATE__", Date.today.iso8601)
      File.write(destination, starter, mode: "w", encoding: "UTF-8")
      out.puts "Initialized: #{destination}"
    end

    def self.validate_file(path, out: $stdout)
      data = Loader.load(path)
      result = Validator.new(data).validate!
      print_validation(data, path, result, out)
      data
    end

    def self.render_file(input_path, output_path, out: $stdout)
      input = File.expand_path(input_path)
      output = File.expand_path(output_path)
      raise InputError, "input and output paths must differ" if input == output

      data = Loader.load(input)
      result = Validator.new(data).validate!
      html = Renderer.new(data).render
      StaticVerifier.verify!(html)
      atomic_write(output, html)
      print_validation(data, input, result, out)
      out.puts "Rendered: #{output}"
      out.puts "SHA256: #{Digest::SHA256.hexdigest(html)}"
      output
    end

    def self.atomic_write(path, content)
      FileUtils.mkdir_p(File.dirname(path))
      Tempfile.create([".technical-explainer-", ".html"], File.dirname(path), encoding: "UTF-8") do |file|
        file.write(content)
        file.flush
        file.fsync
        File.chmod(0o644, file.path)
        File.rename(file.path, path)
      end
    end

    def self.print_validation(data, path, result, out)
      out.puts "Valid: #{File.expand_path(path)}"
      out.puts "Sections: #{data.fetch('sections').length}"
      out.puts "Sources: #{data.fetch('sources', []).length}"
      result.warnings.each { |warning| out.puts "Warning: #{warning}" }
    end

    def self.require_arity!(argv, count, form)
      raise InputError, "usage: render_explainer.rb #{form}" unless argv.length == count
    end

    def self.usage
      <<~TEXT
        Usage:
          render_explainer.rb init <explainer.yaml>
          render_explainer.rb validate <explainer.yaml>
          render_explainer.rb render <explainer.yaml> <index.html>
      TEXT
    end

    private_class_method :atomic_write, :print_validation, :require_arity!
  end
end

if $PROGRAM_NAME == __FILE__
  exit BuildTechnicalExplainer::CLI.run(ARGV)
end
