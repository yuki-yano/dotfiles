#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi/escape"
require "date"
require "digest"
require "base64"
require "erb"
require "fileutils"
require "json"
require "pathname"
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
  SCHEMA_VERSION = 2
  RENDERER_VERSION = 2
  MAX_IMAGE_BYTES = 5 * 1024 * 1024
  MAX_IMAGE_PIXELS = 16_000_000

  ID_PATTERN = /\A[a-z][a-z0-9]*(?:-[a-z0-9]+)*\z/
  SHA256_PATTERN = /\A[0-9a-f]{64}\z/
  DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/
  KINDS = %w[research audit comparison decision implementation-report].freeze
  STATUSES = %w[draft final].freeze
  VISIBILITIES = %w[private shareable].freeze
  BLOCK_TYPES = %w[prose list table code callout checklist details chart diagram image findings].freeze
  LIST_STYLES = %w[bullet number].freeze
  INLINE_STYLES = %w[plain strong code].freeze
  CALLOUT_TONES = %w[neutral info success warning critical].freeze
  EMPHASES = %w[normal strong].freeze
  CHART_KINDS = %w[line bar].freeze
  DIAGRAM_KINDS = %w[flow dependency sequence composite].freeze
  DIAGRAM_DIRECTIONS = %w[horizontal vertical].freeze
  VISUAL_FORMS = %w[none table chart diagram image].freeze
  IMAGE_MEDIA_TYPES = %w[image/png image/jpeg image/webp].freeze
  IMAGE_PROVENANCE_KINDS = %w[provided generated captured].freeze
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

    ROOT_KEYS = %w[version document visual_plan metrics sections sources related_artifacts].freeze
    DOCUMENT_KEYS = %w[title summary kind status visibility updated audience tags].freeze
    VISUAL_PLAN_KEYS = %w[section goal form reason].freeze
    METRIC_KEYS = %w[label value note].freeze
    SECTION_KEYS = %w[id title lead blocks].freeze
    SOURCE_KEYS = %w[id title href accessed note].freeze
    ARTIFACT_KEYS = %w[id title href relation note].freeze
    COMMON_BLOCK_KEYS = %w[id type refs].freeze
    BLOCK_KEYS = {
      "prose" => %w[text runs],
      "list" => %w[style items],
      "table" => %w[caption columns rows],
      "code" => %w[language caption content],
      "callout" => %w[tone title text],
      "checklist" => %w[title items],
      "details" => %w[summary open blocks],
      "chart" => %w[kind title x_label y_label unit labels series],
      "diagram" => %w[kind title summary description direction layout groups nodes edges],
      "image" => %w[title alt caption description asset provenance],
      "findings" => %w[id title facets items]
    }.freeze

    def initialize(data)
      @data = data
      @errors = []
      @warnings = []
      @section_ids = []
      @source_ids = []
      @artifact_ids = []
      @block_ids = []
      @finding_ids = []
      @refs = []
      @visual_plan_sections = []
    end

    def validate!
      validate_root
      raise ValidationError, @errors unless @errors.empty?

      Result.new(warnings: @warnings.freeze)
    end

    private

    def validate_root
      check_keys(@data, ROOT_KEYS, "root")
      add_error("version", "must be #{SCHEMA_VERSION}") unless @data["version"] == SCHEMA_VERSION

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
      validate_unique_ids(@block_ids, "blocks")
      validate_unique_values(@finding_ids, "findings", "findings ID")
      validate_visual_plan

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

    def validate_visual_plan
      unless @data.key?("visual_plan")
        add_error("visual_plan", "is required")
        return
      end

      decisions = expect_array(@data["visual_plan"], "visual_plan")
      add_error("visual_plan", "must contain 1 to 12 decisions") unless decisions.length.between?(1, 12)
      decisions.each_with_index do |decision, index|
        path = "visual_plan[#{index}]"
        decision = expect_hash(decision, path)
        next unless decision

        check_keys(decision, VISUAL_PLAN_KEYS, path)
        section = required_id(decision, "section", path)
        @visual_plan_sections << section if section
        required_string(decision, "goal", path, max: 240)
        enum(decision["form"], VISUAL_FORMS, "#{path}.form")
        required_string(decision, "reason", path, max: 500)
        add_error("#{path}.section", "references unknown section '#{section}'") if section && !@section_ids.include?(section)
      end
      validate_unique_values(@visual_plan_sections, "visual_plan", "section decision")
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
      id = required_id(block, "id", path)
      @block_ids << id if id
      validate_refs(block.fetch("refs", []), "#{path}.refs")
      add_error("#{path}.type", "details cannot be nested") if nested && type == "details"
      add_error("#{path}.type", "findings cannot be nested") if nested && type == "findings"

      case type
      when "prose"
        validate_text_or_runs(block, path)
      when "list"
        enum(block.fetch("style", "bullet"), LIST_STYLES, "#{path}.style")
        items = expect_array(block["items"], "#{path}.items")
        add_error("#{path}.items", "must contain at least one item") if items.empty?
        items.each_with_index { |item, index| validate_text_value(item, "#{path}.items[#{index}]", max: 2_000) }
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
      when "image"
        validate_image(block, path)
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
      if block["kind"] == "composite"
        validate_composite_diagram(block, path)
        return
      end
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

    def validate_composite_diagram(block, path)
      required_string(block, "summary", path, max: 500)
      optional_string(block, "description", path, max: 4_000)
      add_error("#{path}.direction", "is not used by composite diagrams") if block.key?("direction")
      add_error("#{path}.edges", "is not used by composite diagrams") if block.key?("edges")

      nodes = expect_array(block["nodes"], "#{path}.nodes")
      add_error("#{path}.nodes", "must contain 2 to 16 nodes") unless nodes.length.between?(2, 16)
      node_ids = []
      nodes.each_with_index do |node, index|
        node_path = "#{path}.nodes[#{index}]"
        node = expect_hash(node, node_path)
        next unless node

        check_keys(node, %w[id label notes metric tone emphasis], node_path)
        id = required_id(node, "id", node_path)
        node_ids << id if id
        required_string(node, "label", node_path, max: 80)
        notes = expect_array(node.fetch("notes", []), "#{node_path}.notes")
        add_error("#{node_path}.notes", "must contain no more than 4 items") if notes.length > 4
        notes.each_with_index { |note, note_index| string(note, "#{node_path}.notes[#{note_index}]", max: 160) }
        optional_string(node, "metric", node_path, max: 160)
        enum(node.fetch("tone", "neutral"), CALLOUT_TONES, "#{node_path}.tone")
        enum(node.fetch("emphasis", "normal"), EMPHASES, "#{node_path}.emphasis")
      end
      validate_unique_values(node_ids, "#{path}.nodes", "node ID")

      groups = expect_array(block.fetch("groups", []), "#{path}.groups")
      add_error("#{path}.groups", "must contain no more than 4 groups") if groups.length > 4
      group_ids = []
      group_layout_ids = []
      groups.each_with_index do |group, index|
        group_path = "#{path}.groups[#{index}]"
        group = expect_hash(group, group_path)
        next unless group

        check_keys(group, %w[id label tone emphasis layout], group_path)
        id = required_id(group, "id", group_path)
        group_ids << id if id
        required_string(group, "label", group_path, max: 100)
        enum(group.fetch("tone", "neutral"), CALLOUT_TONES, "#{group_path}.tone")
        enum(group.fetch("emphasis", "normal"), EMPHASES, "#{group_path}.emphasis")
        group_layout_ids.concat(validate_composite_layout(group["layout"], "#{group_path}.layout", allowed_ids: node_ids))
      end
      validate_unique_values(group_ids, "#{path}.groups", "group ID")
      collisions = node_ids & group_ids
      collisions.each { |id| add_error(path, "node and group IDs collide at '#{id}'") }

      top_ids = validate_composite_layout(block["layout"], "#{path}.layout", allowed_ids: node_ids + group_ids)
      group_ids.each do |id|
        add_error("#{path}.layout", "group '#{id}' must appear exactly once") unless top_ids.count(id) == 1
      end
      node_ids.each do |id|
        count = top_ids.count(id) + group_layout_ids.count(id)
        add_error(path, "node '#{id}' must appear exactly once in layouts") unless count == 1
      end
    end

    def validate_composite_layout(layout, path, allowed_ids:)
      layout = expect_hash(layout, path)
      return [] unless layout

      check_keys(layout, %w[rows], path)
      rows = expect_array(layout["rows"], "#{path}.rows")
      add_error("#{path}.rows", "must contain 1 to 4 rows") unless rows.length.between?(1, 4)
      ids = []
      rows.each_with_index do |row, row_index|
        row_path = "#{path}.rows[#{row_index}]"
        row = expect_array(row, row_path)
        add_error(row_path, "must contain 1 to 4 cells") unless row.length.between?(1, 4)
        row.each_with_index do |id, cell_index|
          unless id?(id)
            add_error("#{row_path}[#{cell_index}]", "must be a lowercase node or group ID")
            next
          end
          ids << id
          add_error("#{row_path}[#{cell_index}]", "references unknown ID '#{id}'") unless allowed_ids.include?(id)
        end
      end
      validate_unique_values(ids, path, "layout ID")
      ids
    end

    def validate_image(block, path)
      required_string(block, "title", path, max: 240)
      required_string(block, "alt", path, max: 500)
      optional_string(block, "caption", path, max: 1_000)
      optional_string(block, "description", path, max: 4_000)

      asset = expect_hash(block["asset"], "#{path}.asset")
      if asset
        check_keys(asset, %w[path media_type sha256 width height byte_size], "#{path}.asset")
        required_string(asset, "path", "#{path}.asset", max: 500)
        enum(asset["media_type"], IMAGE_MEDIA_TYPES, "#{path}.asset.media_type")
        required_string(asset, "sha256", "#{path}.asset", max: 64)
        add_error("#{path}.asset.sha256", "must be a lowercase SHA-256 digest") unless asset["sha256"].is_a?(String) && asset["sha256"].match?(SHA256_PATTERN)
        %w[width height byte_size].each do |key|
          value = asset[key]
          add_error("#{path}.asset.#{key}", "must be a positive integer") unless value.is_a?(Integer) && value.positive?
        end
      end

      provenance = expect_hash(block["provenance"], "#{path}.provenance")
      return unless provenance

      check_keys(provenance, %w[kind tool version created rights sharing_reviewed source_refs], "#{path}.provenance")
      enum(provenance["kind"], IMAGE_PROVENANCE_KINDS, "#{path}.provenance.kind")
      optional_string(provenance, "tool", "#{path}.provenance", max: 160)
      optional_string(provenance, "version", "#{path}.provenance", max: 80)
      date(provenance["created"], "#{path}.provenance.created") if provenance.key?("created")
      required_string(provenance, "rights", "#{path}.provenance", max: 240)
      boolean(provenance["sharing_reviewed"], "#{path}.provenance.sharing_reviewed") if provenance.key?("sharing_reviewed")
      validate_refs(provenance.fetch("source_refs", []), "#{path}.provenance.source_refs")
      if @data.dig("document", "visibility") == "shareable" && provenance["sharing_reviewed"] != true
        add_error("#{path}.provenance.sharing_reviewed", "must be true for shareable image blocks")
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
        validate_table_cell(cell, "#{path}[#{index}]")
      end
    end

    def validate_table_cell(cell, path)
      return if scalar?(cell) || cell.nil?

      cell = expect_hash(cell, path)
      return unless cell

      check_keys(cell, %w[text tone emphasis], path)
      required_scalar(cell, "text", path)
      enum(cell.fetch("tone", "neutral"), CALLOUT_TONES, "#{path}.tone")
      enum(cell.fetch("emphasis", "normal"), EMPHASES, "#{path}.emphasis")
    end

    def validate_text_or_runs(block, path)
      has_text = block.key?("text")
      has_runs = block.key?("runs")
      add_error(path, "must contain exactly one of text or runs") unless has_text ^ has_runs
      required_string(block, "text", path, max: 20_000) if has_text
      validate_runs(block["runs"], "#{path}.runs", max: 20_000) if has_runs
    end

    def validate_text_value(value, path, max:)
      if value.is_a?(String)
        string(value, path, max: max)
        return
      end
      item = expect_hash(value, path)
      return unless item

      check_keys(item, %w[runs], path)
      validate_runs(item["runs"], "#{path}.runs", max: max)
    end

    def validate_runs(value, path, max:)
      runs = expect_array(value, path)
      add_error(path, "must contain 1 to 40 runs") unless runs.length.between?(1, 40)
      total = 0
      runs.each_with_index do |run, index|
        run_path = "#{path}[#{index}]"
        run = expect_hash(run, run_path)
        next unless run

        check_keys(run, %w[text style], run_path)
        required_string(run, "text", run_path, max: max)
        total += run["text"].length if run["text"].is_a?(String)
        enum(run.fetch("style", "plain"), INLINE_STYLES, "#{run_path}.style")
      end
      add_error(path, "combined text must be at most #{max} characters") if total > max
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

  class AssetRegistry
    Record = Data.define(:block_id, :path, :media_type, :sha256, :width, :height, :byte_size, :data_uri, :provenance)

    def self.prepare(data, input_path)
      base = File.realpath(File.dirname(File.expand_path(input_path)))
      records = {}
      each_block(data.fetch("sections")) do |block|
        next unless block["type"] == "image"

        record = prepare_image(block, base)
        records[record.block_id] = record
      end
      records.freeze
    rescue Errno::ENOENT, Errno::EACCES, ArgumentError => e
      raise ValidationError, ["asset: #{e.message}"]
    end

    def self.inspect_file(path)
      real = File.realpath(File.expand_path(path))
      bytes = File.binread(real)
      raise ValidationError, ["image asset: exceeds #{MAX_IMAGE_BYTES} bytes"] if bytes.bytesize > MAX_IMAGE_BYTES

      media_type, width, height = inspect_image(bytes)
      raise ValidationError, ["image asset: exceeds #{MAX_IMAGE_PIXELS} pixels"] if width * height > MAX_IMAGE_PIXELS

      {
        "media_type" => media_type,
        "sha256" => Digest::SHA256.hexdigest(bytes),
        "width" => width,
        "height" => height,
        "byte_size" => bytes.bytesize
      }
    rescue Errno::ENOENT, Errno::EACCES, ArgumentError => e
      raise ValidationError, ["image asset: #{e.message}"]
    end

    def self.each_block(sections, &block)
      sections.each do |section|
        section.fetch("blocks").each do |entry|
          yield entry
          each_block([{ "blocks" => entry.fetch("blocks") }], &block) if entry["type"] == "details"
        end
      end
    end

    def self.prepare_image(block, base)
      asset = block.fetch("asset")
      relative = asset.fetch("path")
      unsafe_relative = Pathname.new(relative).absolute? || relative.start_with?("~") || relative.include?("\0")
      if unsafe_relative
        raise ValidationError, ["image #{block.fetch('id')}: asset path must be a plain relative path"]
      end

      expanded = File.expand_path(relative, base)
      real = File.realpath(expanded)
      prefix = "#{base}#{File::SEPARATOR}"
      unless real.start_with?(prefix)
        raise ValidationError, ["image #{block.fetch('id')}: asset path escapes the YAML directory"]
      end
      bytes = File.binread(real)
      raise ValidationError, ["image #{block.fetch('id')}: asset exceeds #{MAX_IMAGE_BYTES} bytes"] if bytes.bytesize > MAX_IMAGE_BYTES

      media_type, width, height = inspect_image(bytes)
      sha256 = Digest::SHA256.hexdigest(bytes)
      expected = {
        "media_type" => media_type,
        "sha256" => sha256,
        "width" => width,
        "height" => height,
        "byte_size" => bytes.bytesize
      }
      expected.each do |key, value|
        next if asset[key] == value

        raise ValidationError, ["image #{block.fetch('id')}: declared #{key} does not match the asset"]
      end
      raise ValidationError, ["image #{block.fetch('id')}: asset exceeds #{MAX_IMAGE_PIXELS} pixels"] if width * height > MAX_IMAGE_PIXELS

      Record.new(
        block_id: block.fetch("id"),
        path: relative,
        media_type: media_type,
        sha256: sha256,
        width: width,
        height: height,
        byte_size: bytes.bytesize,
        data_uri: "data:#{media_type};base64,#{Base64.strict_encode64(bytes)}",
        provenance: block.fetch("provenance")
      )
    end

    def self.inspect_image(bytes)
      if bytes.start_with?("\x89PNG\r\n\x1a\n".b)
        return inspect_png(bytes)
      end
      return inspect_jpeg(bytes) if bytes.start_with?("\xff\xd8".b)
      return inspect_webp(bytes) if bytes.start_with?("RIFF".b) && bytes.byteslice(8, 4) == "WEBP"

      raise ValidationError, ["image asset: unsupported or invalid image format"]
    end

    def self.inspect_png(bytes)
      offset = 8
      chunks = []
      while offset + 12 <= bytes.bytesize
        length = bytes.byteslice(offset, 4).unpack1("N")
        type = bytes.byteslice(offset + 4, 4)
        chunk_end = offset + 12 + length
        raise ValidationError, ["image asset: truncated PNG chunk"] if chunk_end > bytes.bytesize

        chunks << [type, offset + 8, length]
        offset = chunk_end
        break if type == "IEND"
      end
      raise ValidationError, ["image asset: invalid PNG chunk structure"] unless offset == bytes.bytesize

      ihdr = chunks.first
      unless ihdr && ihdr[0] == "IHDR" && ihdr[2] == 13
        raise ValidationError, ["image asset: invalid PNG header"]
      end
      raise ValidationError, ["image asset: animated PNG is not supported"] if chunks.any? { |type,| type == "acTL" }

      metadata = chunks.map(&:first) & %w[tEXt zTXt iTXt eXIf]
      unless metadata.empty?
        raise ValidationError, ["image asset: PNG metadata chunk #{metadata.first} is not supported"]
      end

      width = bytes.byteslice(ihdr[1], 4).unpack1("N")
      height = bytes.byteslice(ihdr[1] + 4, 4).unpack1("N")
      raise ValidationError, ["image asset: invalid PNG dimensions"] unless width.positive? && height.positive?

      ["image/png", width, height]
    end

    def self.inspect_jpeg(bytes)
      offset = 2
      while offset + 9 < bytes.bytesize
        offset += 1 while offset < bytes.bytesize && bytes.getbyte(offset) != 0xff
        offset += 1 while offset < bytes.bytesize && bytes.getbyte(offset) == 0xff
        marker = bytes.getbyte(offset)
        offset += 1
        next if marker.nil? || marker == 0xd8 || marker == 0xd9

        length = bytes.byteslice(offset, 2)&.unpack1("n")
        break unless length && length >= 2 && offset + length <= bytes.bytesize
        raise ValidationError, ["image asset: JPEG metadata/comments are not supported"] if marker == 0xe1 || marker == 0xfe
        if (0xc0..0xcf).include?(marker) && ![0xc4, 0xc8, 0xcc].include?(marker)
          height = bytes.byteslice(offset + 3, 2).unpack1("n")
          width = bytes.byteslice(offset + 5, 2).unpack1("n")
          return ["image/jpeg", width, height]
        end
        offset += length
      end
      raise ValidationError, ["image asset: invalid JPEG dimensions"]
    end

    def self.inspect_webp(bytes)
      declared_size = bytes.byteslice(4, 4)&.unpack1("V")
      unless declared_size && declared_size + 8 == bytes.bytesize
        raise ValidationError, ["image asset: invalid WebP RIFF size"]
      end

      chunks = []
      offset = 12
      while offset + 8 <= bytes.bytesize
        type = bytes.byteslice(offset, 4)
        length = bytes.byteslice(offset + 4, 4).unpack1("V")
        data_offset = offset + 8
        chunk_end = data_offset + length
        padded_end = chunk_end + (length.odd? ? 1 : 0)
        raise ValidationError, ["image asset: truncated WebP chunk"] if padded_end > bytes.bytesize

        chunks << [type, data_offset, length]
        offset = padded_end
      end
      raise ValidationError, ["image asset: invalid WebP chunk structure"] unless offset == bytes.bytesize
      if chunks.any? { |type,| type == "EXIF" || type == "XMP " }
        raise ValidationError, ["image asset: WebP EXIF/XMP metadata is not supported"]
      end
      if chunks.any? { |type,| type == "ANIM" || type == "ANMF" }
        raise ValidationError, ["image asset: animated WebP is not supported"]
      end

      dimensions = nil
      chunks.each do |type, data_offset, length|
        case type
        when "VP8X"
          raise ValidationError, ["image asset: truncated WebP VP8X chunk"] if length < 10
          raise ValidationError, ["image asset: animated WebP is not supported"] if (bytes.getbyte(data_offset).to_i & 0x02).positive?
          dimensions ||= [1 + little_u24(bytes, data_offset + 4), 1 + little_u24(bytes, data_offset + 7)]
        when "VP8 "
          raise ValidationError, ["image asset: invalid WebP dimensions"] if length < 10 ||
            bytes.byteslice(data_offset + 3, 3) != "\x9d\x01\x2a".b
          dimensions ||= [
            bytes.byteslice(data_offset + 6, 2).unpack1("v") & 0x3fff,
            bytes.byteslice(data_offset + 8, 2).unpack1("v") & 0x3fff
          ]
        when "VP8L"
          raise ValidationError, ["image asset: invalid WebP dimensions"] if length < 5 ||
            bytes.getbyte(data_offset) != 0x2f
          bits = bytes.byteslice(data_offset + 1, 4).unpack1("V")
          dimensions ||= [1 + (bits & 0x3fff), 1 + ((bits >> 14) & 0x3fff)]
        end
      end
      raise ValidationError, ["image asset: invalid WebP header"] unless dimensions

      width, height = dimensions
      raise ValidationError, ["image asset: invalid WebP dimensions"] unless width.positive? && height.positive?

      ["image/webp", width, height]
    end

    def self.little_u24(bytes, offset)
      bytes.getbyte(offset).to_i | (bytes.getbyte(offset + 1).to_i << 8) | (bytes.getbyte(offset + 2).to_i << 16)
    end

    private_class_method :each_block, :prepare_image, :inspect_image, :inspect_png, :inspect_jpeg, :inspect_webp, :little_u24
  end

  class Renderer
    def initialize(data, assets: {})
      @data = data
      @document = data.fetch("document")
      @sources = data.fetch("sources", [])
      @artifacts = data.fetch("related_artifacts", [])
      @source_by_id = @sources.to_h { |source| [source.fetch("id"), source] }
      @assets = assets
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
      asset_text = @assets.empty? ? "外部assetなし" : "画像asset埋め込み済み"
      @footer_capability = @script.empty? ? "#{asset_text}・JavaScriptなし" : "#{asset_text}・固定filterのみ"

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
      image_policy = @assets.empty? ? "'none'" : "data:"
      "default-src 'none'; style-src 'unsafe-inline'; img-src #{image_policy}; font-src 'none'; " \
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
      block_id = block.fetch("id")
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
             when "image" then render_image(block)
             when "findings" then render_findings(block)
             end
      %(<div id="block-#{h(block_id)}" class="content-block #{h(block.fetch('type'))}">#{body}#{render_refs(block.fetch('refs', []))}</div>)
    end

    def render_prose(block)
      return %(<p>#{render_runs(block.fetch("runs"))}</p>) if block.key?("runs")

      render_paragraphs(block.fetch("text"))
    end

    def render_paragraphs(text)
      text.split(/\n{2,}/).map do |paragraph|
        %(<p>#{h(paragraph.strip).gsub("\n", "<br>\n")}</p>)
      end.join
    end

    def render_list(block)
      tag = block.fetch("style", "bullet") == "number" ? "ol" : "ul"
      items = block.fetch("items").map do |item|
        content = item.is_a?(Hash) ? render_runs(item.fetch("runs")) : h(item)
        %(<li>#{content}</li>)
      end.join
      %(<#{tag} class="content-list">#{items}</#{tag}>)
    end

    def render_runs(runs)
      runs.map do |run|
        text = h(run.fetch("text"))
        case run.fetch("style", "plain")
        when "strong" then %(<strong>#{text}</strong>)
        when "code" then %(<code class="inline-code">#{text}</code>)
        else text
        end
      end.join
    end

    def render_table(block)
      columns = block.fetch("columns")
      caption = block["caption"] ? %(<caption>#{h(block['caption'])}</caption>) : ""
      head = columns.map { |column| %(<th scope="col">#{h(column)}</th>) }.join
      rows = block.fetch("rows").map do |row|
        cells = row.each_with_index.map do |cell, index|
          content, classes = render_table_cell(cell)
          class_attr = classes.empty? ? "" : %( class="#{classes.join(' ')}")
          %(<td#{class_attr} data-label="#{h(columns[index])}">#{content}</td>)
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

    def render_table_cell(cell)
      return [h(cell), []] unless cell.is_a?(Hash)

      tone = cell.fetch("tone", "neutral")
      emphasis = cell.fetch("emphasis", "normal")
      [h(cell.fetch("text")), ["tone-#{h(tone)}", "emphasis-#{h(emphasis)}"]]
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
      return render_composite_diagram(block, block_id) if block.fetch("kind") == "composite"

      block.fetch("kind") == "sequence" ? render_sequence_diagram(block, block_id) : render_flow_diagram(block, block_id)
    end

    def render_composite_diagram(block, block_id)
      node_lookup = block.fetch("nodes").to_h { |node| [node.fetch("id"), node] }
      group_lookup = block.fetch("groups", []).to_h { |group| [group.fetch("id"), group] }
      layout = render_composite_layout(block.fetch("layout"), block_id, node_lookup, group_lookup)
      description = block["description"] ? %(<p class="composite-description">#{h(block['description'])}</p>) : ""
      structure = render_composite_structure(block)
      <<~HTML
        <figure class="composite-figure" role="group" aria-labelledby="#{h(block_id)}-title">
          <figcaption id="#{h(block_id)}-title">#{h(block.fetch('title'))}</figcaption>
          <p class="composite-summary">#{h(block.fetch('summary'))}</p>
          #{description}
          <div class="composite-diagram">#{layout}</div>
          <details class="visual-data">
            <summary>図の構造をテキストで確認</summary>
            <div class="composite-structure">#{structure}</div>
          </details>
        </figure>
      HTML
    end

    def render_composite_layout(layout, block_id, node_lookup, group_lookup)
      layout.fetch("rows").map do |row|
        cells = row.map do |id|
          is_group = group_lookup.key?(id)
          content = if is_group
                      render_composite_group(group_lookup.fetch(id), block_id, node_lookup)
                    else
                      render_composite_node(node_lookup.fetch(id), block_id)
                    end
          group_class = is_group ? " composite-cell-group" : ""
          %(<div class="composite-cell#{group_class}">#{content}</div>)
        end
        joined = cells.each_with_index.map do |cell, index|
          arrow = index < cells.length - 1 ? %(<span class="composite-arrow" aria-hidden="true">→</span>) : ""
          "#{cell}#{arrow}"
        end.join
        %(<div class="composite-row">#{joined}</div>)
      end.join
    end

    def render_composite_group(group, block_id, node_lookup)
      tone = group.fetch("tone", "neutral")
      emphasis = group.fetch("emphasis", "normal")
      body = render_composite_layout(group.fetch("layout"), block_id, node_lookup, {})
      <<~HTML
        <section id="#{h(block_id)}-group-#{h(group.fetch('id'))}" class="composite-group tone-#{h(tone)} emphasis-#{h(emphasis)}">
          <h3>#{h(group.fetch('label'))}</h3>
          #{body}
        </section>
      HTML
    end

    def render_composite_node(node, block_id)
      tone = node.fetch("tone", "neutral")
      emphasis = node.fetch("emphasis", "normal")
      notes = node.fetch("notes", []).map { |note| %(<li>#{h(note)}</li>) }.join
      notes_html = notes.empty? ? "" : %(<ul>#{notes}</ul>)
      metric = node["metric"] ? %(<p class="composite-metric">#{h(node['metric'])}</p>) : ""
      <<~HTML
        <article id="#{h(block_id)}-node-#{h(node.fetch('id'))}" class="composite-node tone-#{h(tone)} emphasis-#{h(emphasis)}">
          <h4>#{h(node.fetch('label'))}</h4>
          #{notes_html}
          #{metric}
        </article>
      HTML
    end

    def render_composite_structure(block)
      groups = block.fetch("groups", []).to_h { |group| [group.fetch("id"), group] }
      nodes = block.fetch("nodes").to_h { |node| [node.fetch("id"), node] }
      rows = block.fetch("layout").fetch("rows").map do |row|
        labels = row.map { |id| groups[id]&.fetch("label") || nodes.fetch(id).fetch("label") }
        %(<li>#{labels.map { |label| h(label) }.join(' → ')}</li>)
      end.join
      group_details = groups.values.map do |group|
        inner = group.fetch("layout").fetch("rows").map do |row|
          %(<li>#{row.map { |id| h(nodes.fetch(id).fetch('label')) }.join(' → ')}</li>)
        end.join
        %(<section><h4>#{h(group.fetch('label'))}</h4><ul>#{inner}</ul></section>)
      end.join
      node_details = nodes.values.map do |node|
        parts = [node.fetch("label"), *node.fetch("notes", []), node["metric"]].compact
        %(<li>#{parts.map { |part| h(part) }.join(' — ')}</li>)
      end.join
      %(<ol>#{rows}</ol>#{group_details}<h4>ノード詳細</h4><ul>#{node_details}</ul>)
    end

    def render_image(block)
      asset = @assets.fetch(block.fetch("id"))
      caption = block["caption"] ? %(<figcaption>#{h(block['caption'])}</figcaption>) : ""
      description = block["description"] ? %(<details class="visual-data"><summary>画像の詳細説明</summary><p>#{h(block['description'])}</p></details>) : ""
      <<~HTML
        <figure class="image-figure">
          <p class="figure-title">#{h(block.fetch('title'))}</p>
          <img src="#{asset.data_uri}" alt="#{h(block.fetch('alt'))}" width="#{asset.width}" height="#{asset.height}" loading="lazy">
          #{caption}
          #{description}
        </figure>
      HTML
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
      when "image-info"
        require_arity!(argv, 1, "image-info <image>")
        out.puts JSON.pretty_generate(AssetRegistry.inspect_file(argv.fetch(0)))
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
      input = File.expand_path(path)
      data = Loader.load(input)
      result = Validator.new(data).validate!
      AssetRegistry.prepare(data, input)
      print_validation(data, input, result, out)
      data
    end

    def self.render_file(input_path, output_path, out: $stdout)
      input = File.expand_path(input_path)
      output = File.expand_path(output_path)
      raise InputError, "input and output paths must differ" if input == output

      data = Loader.load(input)
      result = Validator.new(data).validate!
      assets = AssetRegistry.prepare(data, input)
      html = Renderer.new(data, assets: assets).render
      StaticVerifier.verify!(html)
      manifest = build_manifest(input, html, assets)
      verify_manifest!(html, manifest, assets)
      atomic_write(output, html)
      manifest_path = output.end_with?(".html") ? output.sub(/\.html\z/, ".manifest.json") : "#{output}.manifest.json"
      atomic_write(manifest_path, "#{JSON.pretty_generate(manifest)}\n")
      print_validation(data, input, result, out)
      out.puts "Rendered: #{output}"
      out.puts "Manifest: #{manifest_path}"
      out.puts "SHA256: #{Digest::SHA256.hexdigest(html)}"
      output
    end

    def self.build_manifest(input, html, assets)
      {
        "schema_version" => SCHEMA_VERSION,
        "renderer_version" => RENDERER_VERSION,
        "input_sha256" => Digest::SHA256.file(input).hexdigest,
        "output_sha256" => Digest::SHA256.hexdigest(html),
        "assets" => assets.values.sort_by(&:block_id).map do |asset|
          {
            "block_id" => asset.block_id,
            "path" => asset.path,
            "media_type" => asset.media_type,
            "sha256" => asset.sha256,
            "width" => asset.width,
            "height" => asset.height,
            "byte_size" => asset.byte_size,
            "provenance" => asset.provenance
          }
        end
      }
    end

    def self.verify_manifest!(html, manifest, assets)
      raise ValidationError, ["manifest: output SHA-256 mismatch"] unless manifest["output_sha256"] == Digest::SHA256.hexdigest(html)

      assets.each_value do |asset|
        raise ValidationError, ["manifest: embedded asset missing for '#{asset.block_id}'"] unless html.include?(asset.data_uri)
        entry = manifest.fetch("assets").find { |item| item["block_id"] == asset.block_id }
        raise ValidationError, ["manifest: asset entry missing for '#{asset.block_id}'"] unless entry
        raise ValidationError, ["manifest: asset SHA-256 mismatch for '#{asset.block_id}'"] unless entry["sha256"] == asset.sha256
      end
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
          render_explainer.rb image-info <image>
      TEXT
    end

    private_class_method :atomic_write, :build_manifest, :verify_manifest!, :print_validation, :require_arity!
  end
end

if $PROGRAM_NAME == __FILE__
  exit BuildTechnicalExplainer::CLI.run(ARGV)
end
