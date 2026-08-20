#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require "base64"
require "stringio"
require "tmpdir"
require "zlib"
require_relative "render_explainer"

class RenderExplainerTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("technical-explainer-test")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_research_scenario_renders_compact_source_linked_document
    input = write_yaml("research.yaml", research_yaml)
    output = File.join(@tmpdir, "research.html")
    stdout = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: stdout, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_includes html, "導入価値の評価"
    assert_includes html, "href=\"#source-history\""
    assert_includes html, "id=\"source-history\""
    assert_includes html, "data-label=\"結果\""
    assert_includes html, "script-src 'none'"
    assert_includes html, "font-size: clamp(1.55rem, 2.6vw, 2rem)"
    assert_includes stdout.string, "Sections: 2"
    assert_includes stdout.string, "Sources: 1"
    refute_match(/<script\b/i, html)
    refute_includes html, "class=\"hero\""
  end

  def test_audit_scenario_escapes_content_and_supports_dod_blocks
    input = write_yaml("audit.yaml", audit_yaml)
    output = File.join(@tmpdir, "audit.html")

    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_includes html, "&lt;script&gt;alert(&#39;x&#39;)&lt;/script&gt;"
    assert_includes html, "機能完了条件"
    assert_includes html, "class=\"checkmark\""
    assert_includes html, "@media (max-width: 760px)"
    assert_match(/@media \(max-width: 760px\).*?table,\s+caption,\s+tbody,/m, html)
    assert_includes html, "td::before"
    refute_match(/<script\b/i, html)
  end

  def test_shareable_decision_scenario_accepts_public_sources
    input = write_yaml("decision.yaml", decision_yaml)
    output = File.join(@tmpdir, "decision.html")
    stdout = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: stdout, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_includes html, 'href="https://example.com/decision" target="_blank" rel="noopener noreferrer"'
    assert_includes stdout.string, "Sections: 1"
    assert_includes stdout.string, "Sources: 1"
  end

  def test_advanced_audit_renders_related_artifact_visuals_disclosure_and_fixed_filters
    input = write_yaml("advanced.yaml", advanced_yaml)
    output = File.join(@tmpdir, "advanced.html")

    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_includes html, "id=\"related-artifacts\""
    assert_includes html, "href=\"./sidebar-proposals.html#proposal-b\""
    assert_includes html, "class=\"disclosure\""
    assert_includes html, "class=\"chart-svg\""
    assert_includes html, "class=\"chart-line series-0\""
    assert_includes html, "class=\"diagram-svg\""
    assert_includes html, "marker-end=\"url(#decision-flow-arrow)\""
    assert_includes html, "data-findings"
    assert_includes html, "data-facet-select=\"priority\""
    assert_includes html, "id=\"finding-primary-c01\""
    assert_includes html, "id=\"findings-primary-facet-priority\""
    assert_includes html, "window.addEventListener"
    assert_match(/script-src 'sha256-[A-Za-z0-9+\/=]+'/, html)
    refute_match(/script-src[^;]*unsafe-inline/, html)
    assert HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
  end

  def test_findings_anchors_remain_stable_with_earlier_and_multiple_blocks
    baseline_data = parse_yaml(advanced_yaml)
    baseline_input = write_yaml("findings-baseline.yaml", YAML.dump(baseline_data))
    baseline_output = File.join(@tmpdir, "findings-baseline.html")
    baseline_status = BuildTechnicalExplainer::CLI.run(
      ["render", baseline_input, baseline_output],
      out: StringIO.new,
      err: StringIO.new
    )

    data = parse_yaml(advanced_yaml)
    blocks = data["sections"][0]["blocks"]
    primary = blocks.find { |block| block["type"] == "findings" }
    secondary = Marshal.load(Marshal.dump(primary))
    secondary["id"] = "secondary"
    secondary["title"] = "補足指摘"
    blocks.unshift({ "id" => "earlier-prose", "type" => "prose", "text" => "先行blockを追加する。" })
    blocks << secondary
    input = write_yaml("multiple-findings.yaml", YAML.dump(data))
    output = File.join(@tmpdir, "multiple-findings.html")
    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: StringIO.new)

    assert_equal 0, baseline_status
    assert_equal 0, status
    baseline_html = File.read(baseline_output, encoding: "UTF-8")
    html = File.read(output, encoding: "UTF-8")
    assert_includes baseline_html, 'id="finding-primary-c01"'
    assert_includes html, 'id="finding-primary-c01"'
    assert_includes html, 'id="finding-secondary-c01"'
    assert_includes html, "block.contains(target)"
    assert_equal 1, html.scan(/<script>/).length
    assert HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
  end

  def test_findings_require_unique_explicit_ids
    missing = parse_yaml(advanced_yaml)
    missing_block = missing["sections"][0]["blocks"].find { |block| block["type"] == "findings" }
    missing_block.delete("id")

    duplicate = parse_yaml(advanced_yaml)
    duplicate_blocks = duplicate["sections"][0]["blocks"]
    duplicate_block = duplicate_blocks.find { |block| block["type"] == "findings" }
    duplicate_blocks << Marshal.load(Marshal.dump(duplicate_block))

    {
      "missing-findings-id" => [missing, ".id: is required"],
      "duplicate-findings-id" => [duplicate, "duplicate findings ID 'primary'"]
    }.each do |name, (data, message)|
      input = write_yaml("#{name}.yaml", YAML.dump(data))
      stderr = StringIO.new
      status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

      assert_equal 2, status, name
      assert_includes stderr.string, message, name
    end
  end

  def test_dense_japanese_visual_labels_are_fitted_and_full_text_is_preserved
    data = parse_yaml(advanced_yaml)
    blocks = data["sections"][0]["blocks"]
    chart = blocks.find { |block| block["type"] == "chart" }
    chart["labels"] = (1..36).map { |index| "第#{index}回の非常に長い測定ラベル" }
    chart["series"].each_with_index do |series, series_index|
      series["values"] = (1..36).map { |index| 100 + index + (series_index * 10) }
    end

    diagram = blocks.find { |block| block["type"] == "diagram" }
    diagram["nodes"] = (1..8).map do |index|
      { "id" => "node-#{index}", "label" => "非常に長い日本語ノード#{index}", "tone" => "info" }
    end
    diagram["edges"] = (1..7).map do |index|
      { "from" => "node-#{index}", "to" => "node-#{index + 1}", "label" => "長い接続条件#{index}" }
    end

    input = write_yaml("dense-labels.yaml", YAML.dump(data))
    output = File.join(@tmpdir, "dense-labels.html")
    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_match(/<svg class="chart-svg".*?<text class="chart-tick"[^>]*>[^<]*…<\/text>/m, html)
    assert_match(/<svg class="diagram-svg".*?<g class="diagram-node[^"]*">.*?<text[^>]*>[^<]*…<\/text>/m, html)
    assert_includes html, "第36回の非常に長い測定ラベル"
    assert_includes html, "非常に長い日本語ノード8"
    assert_includes html, "101ms"
    assert HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
  end

  def test_static_visual_blocks_do_not_enable_javascript
    data = parse_yaml(advanced_yaml)
    data["sections"][0]["blocks"].reject! { |block| block["type"] == "findings" }
    input = write_yaml("static-visuals.yaml", YAML.dump(data))
    output = File.join(@tmpdir, "static-visuals.html")

    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_includes html, "script-src 'none'"
    refute_match(/<script\b/i, html)
  end

  def test_bar_vertical_dependency_and_sequence_variants_render
    data = parse_yaml(advanced_yaml)
    blocks = data["sections"][0]["blocks"]
    chart = blocks.find { |block| block["type"] == "chart" }
    chart["kind"] = "bar"
    chart["series"][0]["values"] = [-20, 0, 30]

    dependency = blocks.find { |block| block["type"] == "diagram" }
    dependency["kind"] = "dependency"
    dependency["direction"] = "vertical"
    sequence = Marshal.load(Marshal.dump(dependency))
    sequence["kind"] = "sequence"
    sequence["id"] = "notification-sequence"
    sequence.delete("direction")
    sequence["title"] = "監査と実装の通知順"
    blocks.insert(blocks.index(dependency) + 1, sequence)

    input = write_yaml("visual-variants.yaml", YAML.dump(data))
    output = File.join(@tmpdir, "visual-variants.html")
    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_includes html, "class=\"chart-bar series-0\""
    assert_includes html, 'viewBox="0 0 720 364"'
    assert_includes html, "class=\"diagram-lifeline\""
    assert_includes html, "監査と実装の通知順"
    assert HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
  end

  def test_invalid_visual_and_filter_contracts_are_rejected
    cases = {}

    chart = parse_yaml(advanced_yaml)
    chart_block = chart["sections"][0]["blocks"].find { |block| block["type"] == "chart" }
    chart_block["series"][0]["values"] = [1]
    cases["chart-values"] = chart

    diagram = parse_yaml(advanced_yaml)
    diagram_block = diagram["sections"][0]["blocks"].find { |block| block["type"] == "diagram" }
    diagram_block["edges"][0]["to"] = "missing"
    cases["diagram-edge"] = diagram

    findings = parse_yaml(advanced_yaml)
    findings_block = findings["sections"][0]["blocks"].find { |block| block["type"] == "findings" }
    findings_block["items"][0]["facets"].delete("priority")
    cases["finding-facet"] = findings

    nested = parse_yaml(advanced_yaml)
    details = nested["sections"][0]["blocks"].find { |block| block["type"] == "details" }
    details["blocks"] = [{
      "id" => "nested-details",
      "type" => "details",
      "summary" => "nested",
      "blocks" => [{ "id" => "nested-prose", "type" => "prose", "text" => "x" }]
    }]
    cases["nested-details"] = nested

    cases.each do |name, data|
      input = write_yaml("invalid-#{name}.yaml", YAML.dump(data))
      stderr = StringIO.new
      status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

      assert_equal 2, status, name
      assert_match(/must have 3 values|unknown node|missing facets|cannot be nested/, stderr.string, name)
    end
  end

  def test_shareable_document_accepts_public_url_paths_named_home
    yaml = decision_yaml.sub("https://example.com/decision", "https://example.com/home/user/decision")
    input = write_yaml("public-home-url.yaml", yaml)

    status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: StringIO.new)

    assert_equal 0, status
  end

  def test_unknown_source_reference_fails_without_writing_html
    yaml = research_yaml.sub("refs: [history]", "refs: [missing]")
    input = write_yaml("unknown-ref.yaml", yaml)
    output = File.join(@tmpdir, "unknown-ref.html")
    stderr = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: stderr)

    assert_equal 2, status
    assert_includes stderr.string, "references unknown source 'missing'"
    refute_path_exists output
  end

  def test_shareable_document_rejects_local_identity_paths
    yaml = decision_yaml.sub("https://example.com/decision", "/Users/private-user/report.md")
    input = write_yaml("leak.yaml", yaml)
    stderr = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

    assert_equal 2, status
    assert_includes stderr.string, "shareable content contains local information"
  end

  def test_unsafe_url_scheme_is_rejected
    yaml = decision_yaml.sub("https://example.com/decision", "javascript:alert(1)")
    input = write_yaml("unsafe-url.yaml", yaml)
    stderr = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

    assert_equal 2, status
    assert_includes stderr.string, "unsupported URL scheme"
  end

  def test_unsafe_url_scheme_with_surrounding_whitespace_is_rejected
    [" javascript:alert(1)", "javascript:alert(1) "].each_with_index do |href, index|
      yaml = decision_yaml.sub("https://example.com/decision", href)
      input = write_yaml("unsafe-url-whitespace-#{index}.yaml", yaml)
      stderr = StringIO.new

      status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

      assert_equal 2, status, href.inspect
      assert_includes stderr.string, "unsupported URL scheme", href.inspect
    end
  end

  def test_empty_mappings_are_rejected_before_rendering
    cases = {}

    document = parse_yaml(research_yaml)
    document["document"] = {}
    cases["document"] = document

    metric = parse_yaml(research_yaml)
    metric["metrics"] = [{}]
    cases["metric"] = metric

    section = parse_yaml(research_yaml)
    section["sections"] = [{}]
    cases["section"] = section

    block = parse_yaml(research_yaml)
    block["sections"][0]["blocks"] = [{}]
    cases["block"] = block

    source = parse_yaml(audit_yaml)
    source["sources"] = [{}]
    cases["source"] = source

    checklist_item = parse_yaml(audit_yaml)
    checklist_item["sections"][0]["blocks"][2]["items"] = [{}]
    cases["checklist-item"] = checklist_item

    cases.each do |name, data|
      input = write_yaml("empty-#{name}.yaml", YAML.dump(data))
      output = File.join(@tmpdir, "empty-#{name}.html")
      stderr = StringIO.new

      status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: stderr)

      assert_equal 2, status, name
      assert_match(/is required|must be one of/, stderr.string, name)
      refute_match(/KeyError/, stderr.string, name)
      refute_path_exists output, name
    end
  end

  def test_unknown_fields_and_table_shape_are_rejected
    yaml = research_yaml
      .sub("status: final", "status: final\n  theme: landing")
      .sub('["直接適合", "9件", "限定用途"]', '["直接適合", "9件"]')
    input = write_yaml("invalid-shape.yaml", yaml)
    stderr = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

    assert_equal 2, status
    assert_includes stderr.string, "unknown fields"
    assert_includes stderr.string, "must have 3 cells"
  end

  def test_yaml_aliases_are_rejected
    yaml = research_yaml.sub(
      'audience: "導入判断者"',
      'audience: &audience "導入判断者"'
    ).sub(
      'tags: ["agent", "skill"]',
      "tags: [*audience]"
    )
    input = write_yaml("alias.yaml", yaml)
    stderr = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

    assert_equal 2, status
    assert_includes stderr.string, "Alias parsing was not enabled"
  end

  def test_render_is_deterministic
    input = write_yaml("deterministic.yaml", research_yaml)
    first = File.join(@tmpdir, "first.html")
    second = File.join(@tmpdir, "second.html")

    first_status = BuildTechnicalExplainer::CLI.run(["render", input, first], out: StringIO.new, err: StringIO.new)
    second_status = BuildTechnicalExplainer::CLI.run(["render", input, second], out: StringIO.new, err: StringIO.new)

    assert_equal 0, first_status
    assert_equal 0, second_status
    assert_equal File.binread(first), File.binread(second)
    assert_equal File.binread(first.sub(".html", ".manifest.json")), File.binread(second.sub(".html", ".manifest.json"))
  end

  def test_version_one_is_rejected_without_fallback
    input = write_yaml("version-one.yaml", research_yaml.sub("version: 2", "version: 1"))
    stderr = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

    assert_equal 2, status
    assert_includes stderr.string, "version: must be 2"
  end

  def test_typed_runs_cells_and_composite_render_as_safe_html
    data = parse_yaml(research_yaml)
    blocks = data["sections"][0]["blocks"]
    blocks[0] = {
      "id" => "typed-prose",
      "type" => "prose",
      "runs" => [
        { "text" => "直列処理: ", "style" => "strong" },
        { "text" => "<unsafe>" },
        { "text" => "PreparedEvalQuery.Eval", "style" => "code" }
      ]
    }
    data["sections"][1]["blocks"][0]["rows"][0][1] = {
      "text" => "0.33s",
      "tone" => "success",
      "emphasis" => "strong"
    }
    blocks << composite_block
    data["visual_plan"][0]["form"] = "diagram"
    input = write_yaml("typed-composite.yaml", YAML.dump(data))
    output = File.join(@tmpdir, "typed-composite.html")

    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_includes html, "<strong>直列処理: </strong>"
    assert_includes html, "&lt;unsafe&gt;"
    assert_includes html, '<code class="inline-code">PreparedEvalQuery.Eval</code>'
    assert_includes html, 'class="tone-success emphasis-strong"'
    assert_includes html, 'class="composite-diagram"'
    assert_includes html, 'id="pipeline-node-rego"'
    assert_includes html, "図の構造をテキストで確認"
    refute_includes html, "<unsafe>"
    assert HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
  end

  def test_image_asset_is_verified_embedded_and_manifested
    bytes = Base64.strict_decode64(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )
    image_path = File.join(@tmpdir, "pixel.png")
    File.binwrite(image_path, bytes)
    data = parse_yaml(research_yaml)
    data["sections"][0]["blocks"] << {
      "id" => "evidence-image",
      "type" => "image",
      "title" => "証拠画像",
      "alt" => "1ピクセルの検証画像",
      "caption" => "asset検証用",
      "description" => "埋め込み画像の検証fixture。",
      "asset" => {
        "path" => "pixel.png",
        "media_type" => "image/png",
        "sha256" => Digest::SHA256.hexdigest(bytes),
        "width" => 1,
        "height" => 1,
        "byte_size" => bytes.bytesize
      },
      "provenance" => {
        "kind" => "provided",
        "rights" => "test fixture",
        "sharing_reviewed" => false,
        "source_refs" => []
      }
    }
    data["visual_plan"][0]["form"] = "image"
    input = write_yaml("image.yaml", YAML.dump(data))
    output = File.join(@tmpdir, "image.html")

    status = BuildTechnicalExplainer::CLI.run(["render", input, output], out: StringIO.new, err: StringIO.new)

    assert_equal 0, status
    html = File.read(output, encoding: "UTF-8")
    assert_includes html, 'img-src data:'
    assert_match(/<img src="data:image\/png;base64,[A-Za-z0-9+\/=]+"/, html)
    manifest = JSON.parse(File.read(output.sub(".html", ".manifest.json"), encoding: "UTF-8"))
    assert_equal Digest::SHA256.hexdigest(html), manifest.fetch("output_sha256")
    assert_equal Digest::SHA256.hexdigest(bytes), manifest.fetch("assets").first.fetch("sha256")

    info_out = StringIO.new
    info_status = BuildTechnicalExplainer::CLI.run(["image-info", image_path], out: info_out, err: StringIO.new)
    assert_equal 0, info_status
    assert_equal 1, JSON.parse(info_out.string).fetch("width")
  end

  def test_image_asset_mismatch_and_shareable_without_review_are_rejected
    bytes = Base64.strict_decode64(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )
    File.binwrite(File.join(@tmpdir, "pixel.png"), bytes)
    data = parse_yaml(research_yaml)
    data["document"]["visibility"] = "shareable"
    data["sections"][0]["blocks"] << {
      "id" => "unsafe-image",
      "type" => "image",
      "title" => "未確認画像",
      "alt" => "未確認画像",
      "asset" => {
        "path" => "pixel.png",
        "media_type" => "image/png",
        "sha256" => "0" * 64,
        "width" => 1,
        "height" => 1,
        "byte_size" => bytes.bytesize
      },
      "provenance" => {
        "kind" => "provided",
        "rights" => "test fixture",
        "sharing_reviewed" => false,
        "source_refs" => []
      }
    }
    input = write_yaml("unsafe-image.yaml", YAML.dump(data))
    stderr = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

    assert_equal 2, status
    assert_includes stderr.string, "must be true for shareable image blocks"
  end

  def test_private_image_digest_mismatch_is_rejected
    bytes = Base64.strict_decode64(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )
    File.binwrite(File.join(@tmpdir, "pixel.png"), bytes)
    data = parse_yaml(research_yaml)
    data["sections"][0]["blocks"] << {
      "id" => "mismatch-image",
      "type" => "image",
      "title" => "不一致画像",
      "alt" => "不一致画像",
      "asset" => {
        "path" => "pixel.png",
        "media_type" => "image/png",
        "sha256" => "0" * 64,
        "width" => 1,
        "height" => 1,
        "byte_size" => bytes.bytesize
      },
      "provenance" => {
        "kind" => "provided",
        "rights" => "test fixture",
        "source_refs" => []
      }
    }
    input = write_yaml("mismatch-image.yaml", YAML.dump(data))
    stderr = StringIO.new

    status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

    assert_equal 2, status
    assert_includes stderr.string, "declared sha256 does not match"
  end

  def test_image_paths_reject_tilde_parent_and_symlink_escape_with_structured_errors
    nested = File.join(@tmpdir, "nested")
    FileUtils.mkdir_p(nested)
    bytes = pixel_png_bytes
    outside = File.join(@tmpdir, "outside.png")
    File.binwrite(outside, bytes)
    File.symlink(outside, File.join(nested, "link.png"))

    {
      "tilde" => ["~nosuch-build-technical-explainer-user/pixel.png", "plain relative path"],
      "parent" => ["../outside.png", "escapes the YAML directory"],
      "symlink" => ["link.png", "escapes the YAML directory"]
    }.each do |name, (asset_path, message)|
      input = File.join(nested, "#{name}.yaml")
      File.write(input, YAML.dump(image_document(asset_path, bytes)), encoding: "UTF-8")
      stderr = StringIO.new

      status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

      assert_equal 2, status, name
      assert_includes stderr.string, message, name
      refute_includes stderr.string, "render_explainer.rb:", name
    end
  end

  def test_image_chunk_scanners_reject_real_metadata_and_animation_without_payload_false_positives
    cases = {
      "png-metadata" => [synthetic_png(extra_chunks: [["tEXt", "author\0private"]]), "PNG metadata chunk tEXt"],
      "png-animation" => [synthetic_png(extra_chunks: [["acTL", [1, 0].pack("NN")]]), "animated PNG"],
      "webp-metadata" => [synthetic_webp(extra_chunks: [["EXIF", "private"]]), "WebP EXIF/XMP metadata"],
      "webp-animation" => [synthetic_webp(extra_chunks: [["ANIM", "\0" * 6]]), "animated WebP"]
    }

    cases.each do |name, (bytes, message)|
      path = File.join(@tmpdir, "#{name}.img")
      File.binwrite(path, bytes)
      stderr = StringIO.new

      status = BuildTechnicalExplainer::CLI.run(["image-info", path], out: StringIO.new, err: stderr)

      assert_equal 2, status, name
      assert_includes stderr.string, message, name
    end

    {
      "png-payload" => synthetic_png(idat_data: "compressed tEXt acTL payload"),
      "webp-payload" => synthetic_webp(payload: "compressed EXIF XMP  ANIM payload")
    }.each do |name, bytes|
      path = File.join(@tmpdir, "#{name}.img")
      File.binwrite(path, bytes)

      status = BuildTechnicalExplainer::CLI.run(["image-info", path], out: StringIO.new, err: StringIO.new)

      assert_equal 0, status, name
    end
  end

  def test_image_magic_byte_and_pixel_limits_are_enforced
    invalid = File.join(@tmpdir, "invalid.png")
    File.binwrite(invalid, "not an image")
    invalid_error = StringIO.new

    invalid_status = BuildTechnicalExplainer::CLI.run(
      ["image-info", invalid],
      out: StringIO.new,
      err: invalid_error
    )

    assert_equal 2, invalid_status
    assert_includes invalid_error.string, "unsupported or invalid image format"

    oversized = File.join(@tmpdir, "oversized.png")
    File.binwrite(oversized, "\x89PNG\r\n\x1a\n".b)
    File.truncate(oversized, BuildTechnicalExplainer::MAX_IMAGE_BYTES + 1)
    oversized_error = StringIO.new

    oversized_status = BuildTechnicalExplainer::CLI.run(
      ["image-info", oversized],
      out: StringIO.new,
      err: oversized_error
    )

    assert_equal 2, oversized_status
    assert_includes oversized_error.string, "exceeds 5242880 bytes"

    excessive_pixels = File.join(@tmpdir, "excessive-pixels.png")
    File.binwrite(excessive_pixels, synthetic_png(width: 4_001, height: 4_000))
    pixels_error = StringIO.new

    pixels_status = BuildTechnicalExplainer::CLI.run(
      ["image-info", excessive_pixels],
      out: StringIO.new,
      err: pixels_error
    )

    assert_equal 2, pixels_status
    assert_includes pixels_error.string, "exceeds 16000000 pixels"
  end

  def test_visual_plan_and_composite_size_boundaries_are_rejected
    cases = {}

    missing_plan = parse_yaml(research_yaml)
    missing_plan.delete("visual_plan")
    cases["missing-plan"] = [missing_plan, "visual_plan: is required"]

    unknown_section = parse_yaml(research_yaml)
    unknown_section["visual_plan"][0]["section"] = "missing"
    cases["unknown-section"] = [unknown_section, "references unknown section"]

    duplicate_section = parse_yaml(research_yaml)
    duplicate_section["visual_plan"] << Marshal.load(Marshal.dump(duplicate_section["visual_plan"][0]))
    cases["duplicate-section"] = [duplicate_section, "duplicate section decision"]

    too_many_nodes = parse_yaml(research_yaml)
    node_block = composite_block
    node_block["groups"] = []
    node_block["nodes"] = (1..17).map { |index| { "id" => "n#{index}", "label" => "node #{index}" } }
    node_block["layout"] = { "rows" => [node_block["nodes"].map { |node| node.fetch("id") }] }
    too_many_nodes["sections"][0]["blocks"] << node_block
    cases["too-many-nodes"] = [too_many_nodes, "nodes: must contain 2 to 16 nodes"]

    too_many_rows = parse_yaml(research_yaml)
    row_block = composite_block
    row_block["groups"] = []
    row_block["nodes"] = (1..5).map { |index| { "id" => "r#{index}", "label" => "row #{index}" } }
    row_block["layout"] = { "rows" => row_block["nodes"].map { |node| [node.fetch("id")] } }
    too_many_rows["sections"][0]["blocks"] << row_block
    cases["too-many-rows"] = [too_many_rows, "rows: must contain 1 to 4 rows"]

    cases.each do |name, (data, message)|
      input = write_yaml("#{name}.yaml", YAML.dump(data))
      stderr = StringIO.new

      status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

      assert_equal 2, status, name
      assert_includes stderr.string, message, name
    end
  end

  def test_composite_unknown_duplicate_and_edges_are_rejected
    {
      "unknown" => lambda { |block| block["layout"]["rows"][0][0] = "missing" },
      "duplicate" => lambda { |block| block["groups"][0]["layout"]["rows"] << ["walk"] },
      "edges" => lambda { |block| block["edges"] = [{ "from" => "walk", "to" => "parse" }] }
    }.each do |name, mutate|
      data = parse_yaml(research_yaml)
      block = composite_block
      mutate.call(block)
      data["sections"][0]["blocks"] << block
      input = write_yaml("invalid-composite-#{name}.yaml", YAML.dump(data))
      stderr = StringIO.new

      status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: stderr)

      assert_equal 2, status, name
      assert_match(/unknown ID|must appear exactly once|is not used by composite/, stderr.string, name)
    end
  end

  def test_fixed_tone_palette_meets_text_contrast
    pairs = [
      ["#244f87", "#e9f0f9"],
      ["#256a4a", "#e8f5ee"],
      ["#855d0d", "#fff6dd"],
      ["#a33a3a", "#fff0ef"]
    ]

    pairs.each do |foreground, background|
      assert_operator contrast_ratio(foreground, background), :>=, 4.5, "#{foreground} on #{background}"
    end
  end

  def test_init_creates_valid_yaml_and_refuses_overwrite
    input = File.join(@tmpdir, "nested", "explainer.yaml")
    stdout = StringIO.new

    first_status = BuildTechnicalExplainer::CLI.run(["init", input], out: stdout, err: StringIO.new)
    second_error = StringIO.new
    second_status = BuildTechnicalExplainer::CLI.run(["init", input], out: StringIO.new, err: second_error)
    validation_status = BuildTechnicalExplainer::CLI.run(["validate", input], out: StringIO.new, err: StringIO.new)

    assert_equal 0, first_status
    assert_equal 2, second_status
    assert_equal 0, validation_status
    assert_includes stdout.string, "Initialized:"
    assert_includes second_error.string, "refusing to overwrite"
  end

  private

  def write_yaml(name, content)
    path = File.join(@tmpdir, name)
    File.write(path, content, encoding: "UTF-8")
    path
  end

  def parse_yaml(content)
    YAML.safe_load(content, permitted_classes: [Date], aliases: false)
  end

  def pixel_png_bytes
    Base64.strict_decode64(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )
  end

  def png_chunk(type, data)
    payload = data.b
    [payload.bytesize].pack("N") + type.b + payload + [Zlib.crc32(type.b + payload)].pack("N")
  end

  def synthetic_png(width: 1, height: 1, extra_chunks: [], idat_data: "")
    ihdr = [width, height, 8, 6, 0, 0, 0].pack("NNCCCCC")
    chunks = [["IHDR", ihdr], *extra_chunks, ["IDAT", idat_data], ["IEND", ""]]
    "\x89PNG\r\n\x1a\n".b + chunks.map { |type, data| png_chunk(type, data) }.join
  end

  def webp_chunk(type, data)
    payload = data.b
    type.b + [payload.bytesize].pack("V") + payload + (payload.bytesize.odd? ? "\0" : "")
  end

  def synthetic_webp(payload: "", extra_chunks: [])
    vp8 = "\0\0\0\x9d\x01\x2a".b + [1, 1].pack("vv") + payload.b
    chunks = [["VP8 ", vp8], *extra_chunks]
    body = "WEBP".b + chunks.map { |type, data| webp_chunk(type, data) }.join
    "RIFF".b + [body.bytesize].pack("V") + body
  end

  def image_document(asset_path, bytes)
    data = parse_yaml(research_yaml)
    data["sections"][0]["blocks"] << {
      "id" => "path-image",
      "type" => "image",
      "title" => "path test",
      "alt" => "path test",
      "asset" => {
        "path" => asset_path,
        "media_type" => "image/png",
        "sha256" => Digest::SHA256.hexdigest(bytes),
        "width" => 1,
        "height" => 1,
        "byte_size" => bytes.bytesize
      },
      "provenance" => {
        "kind" => "provided",
        "rights" => "test fixture",
        "sharing_reviewed" => false,
        "source_refs" => []
      }
    }
    data["visual_plan"][0]["form"] = "image"
    data
  end

  def research_yaml
    <<~YAML
      version: 2
      document:
        title: "導入価値の評価"
        summary: "用途を限定したMVPなら導入価値がある。"
        kind: research
        status: final
        visibility: private
        updated: "2026-07-15"
        audience: "導入判断者"
        tags: ["agent", "skill"]
      metrics:
        - label: "直接適合"
          value: "9 / 812"
          note: "全履歴の1.11%"
      visual_plan:
        - section: conclusion
          goal: "結論を説明する"
          form: none
          reason: "短い文章で足りる"
        - section: evidence
          goal: "観測値を比較する"
          form: table
          reason: "同じ軸の値を並べる"
      sections:
        - id: conclusion
          title: "結論"
          blocks:
            - id: conclusion-prose
              type: prose
              text: "自然言語の依頼から適用し、用途外では発火させない。"
              refs: [history]
        - id: evidence
          title: "根拠"
          lead: "観測値と解釈を分ける。"
          blocks:
            - id: evidence-table
              type: table
              caption: "履歴集計"
              columns: ["指標", "結果", "解釈"]
              rows:
                - ["直接適合", "9件", "限定用途"]
            - id: scope-list
              type: list
              style: bullet
              items:
                - "UIモックには使わない"
                - "通常時はブラウザを開かない"
      sources:
        - id: history
          title: "Agent session history"
          href: "/tmp/history.jsonl"
          accessed: "2026-07-15"
          note: "812 sessions"
    YAML
  end

  def audit_yaml
    <<~YAML
      version: 2
      document:
        title: "回帰監査"
        summary: "未解決事項を修正完了と混同しない。"
        kind: audit
        status: draft
        visibility: private
        updated: "2026-07-15"
        tags: []
      visual_plan:
        - section: findings
          goal: "主要指摘を説明する"
          form: none
          reason: "calloutとchecklistで足りる"
      sections:
        - id: findings
          title: "主要指摘"
          blocks:
            - id: input-warning
              type: callout
              tone: critical
              title: "入力はescapeする"
              text: "<script>alert('x')</script>"
            - id: validation-code
              type: code
              language: bash
              caption: "検証"
              content: "ruby scripts/render_explainer.rb validate explainer.yaml"
            - id: audit-dod
              type: checklist
              title: "機能完了条件"
              items:
                - text: "指摘を分類する"
                  checked: true
                - text: "実装修正を完了する"
                  checked: false
      sources: []
    YAML
  end

  def decision_yaml
    <<~YAML
      version: 2
      document:
        title: "採用判断"
        summary: "公開可能な根拠だけで判断する。"
        kind: decision
        status: final
        visibility: shareable
        updated: "2026-07-15"
        audience: "利用者"
        tags: ["decision"]
      visual_plan:
        - section: recommendation
          goal: "採用判断を伝える"
          form: none
          reason: "短い判断と手順で足りる"
      sections:
        - id: recommendation
          title: "推奨"
          blocks:
            - id: recommendation-prose
              type: prose
              text: "固定rendererを採用する。"
              refs: [decision-record]
            - id: recommendation-steps
              type: list
              style: number
              items:
                - "MVPを作る"
                - "3件で再評価する"
      sources:
        - id: decision-record
          title: "Decision record"
          href: "https://example.com/decision"
          accessed: "2026-07-15"
    YAML
  end

  def advanced_yaml
    <<~YAML
      version: 2
      document:
        title: "UI回帰の技術監査"
        summary: "根拠を残し、視覚案は別成果物として選択する。"
        kind: audit
        status: draft
        visibility: private
        updated: "2026-07-15"
        audience: "実装者とレビュー担当"
        tags: ["audit", "ui"]
      metrics: []
      related_artifacts:
        - id: sidebar-proposals
          title: "Sidebar UI proposals"
          href: "./sidebar-proposals.html#proposal-b"
          relation: visual-spec
          note: "案Bを採用候補として比較中"
      visual_plan:
        - section: evidence
          goal: "処理時間と判断順を説明する"
          form: diagram
          reason: "時系列と関係を図で補助する"
      sections:
        - id: evidence
          title: "根拠と判断"
          blocks:
            - id: audit-details
              type: details
              summary: "監査根拠"
              blocks:
                - id: audit-detail-prose
                  type: prose
                  text: "詳細な観測事実。"
                  refs: [audit-log]
            - id: timing-chart
              type: chart
              kind: line
              title: "処理時間の推移"
              x_label: "試行"
              y_label: "時間"
              unit: "ms"
              labels: ["1", "2", "3"]
              series:
                - name: "before"
                  values: [120, 118, 121]
                - name: "after"
                  values: [80, 76, 74]
            - id: decision-flow
              type: diagram
              kind: flow
              title: "判断から実装まで"
              direction: horizontal
              nodes:
                - id: audit
                  label: "監査"
                  tone: info
                - id: proposal
                  label: "UI案選択"
                  tone: warning
                - id: implementation
                  label: "実装"
                  tone: success
              edges:
                - from: audit
                  to: proposal
                  label: "制約を渡す"
                - from: proposal
                  to: implementation
                  label: "案B"
            - type: findings
              id: primary
              title: "主要指摘"
              facets:
                - id: priority
                  label: "優先度"
                  values:
                    - id: must-fix
                      label: "must-fix"
                    - id: should-fix
                      label: "should-fix"
                - id: surface
                  label: "対象"
                  values:
                    - id: sidebar
                      label: "sidebar"
                    - id: statusline
                      label: "statusline"
              items:
                - id: c01
                  title: "選択状態が一致しない"
                  summary: "表示と操作対象が異なる。"
                  facets:
                    priority: must-fix
                    surface: sidebar
                  details:
                    - label: "推奨対応"
                      text: "stable IDを共通に使う。"
                  refs: [audit-log]
                - id: c02
                  title: "表示予算が不足する"
                  summary: "statuslineの一部が省略される。"
                  facets:
                    priority: should-fix
                    surface: statusline
                  details: []
      sources:
        - id: audit-log
          title: "監査ログ"
          href: "./audit.log"
          accessed: "2026-07-15"
    YAML
  end

  def composite_block
    {
      "id" => "pipeline",
      "type" => "diagram",
      "kind" => "composite",
      "title" => "評価パイプライン",
      "summary" => "walk後にparseし、ASTノードごとに評価する。",
      "layout" => { "rows" => [%w[walk parse ast-loop]] },
      "groups" => [{
        "id" => "ast-loop",
        "label" => "AST loop",
        "tone" => "info",
        "emphasis" => "normal",
        "layout" => { "rows" => [%w[clone json], ["rego"]] }
      }],
      "nodes" => [
        { "id" => "walk", "label" => "walk", "notes" => [".go列挙"] },
        { "id" => "parse", "label" => "parse", "tone" => "success", "emphasis" => "strong" },
        { "id" => "clone", "label" => "deep clone", "tone" => "critical", "emphasis" => "strong" },
        { "id" => "json", "label" => "JSON往復" },
        { "id" => "rego", "label" => "Rego評価", "metric" => "441µs → 2.0µs" }
      ]
    }
  end

  def contrast_ratio(first, second)
    values = [first, second].map do |color|
      color.delete_prefix("#").scan(/../).map { |channel| channel.to_i(16) / 255.0 }.map do |channel|
        channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4
      end.then { |rgb| 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2] }
    end
    (values.max + 0.05) / (values.min + 0.05)
  end
end
