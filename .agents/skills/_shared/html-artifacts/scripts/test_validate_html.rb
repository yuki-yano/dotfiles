#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "minitest/autorun"
require "stringio"
require "tmpdir"
require_relative "validate_html"

class HtmlArtifactValidatorTest < Minitest::Test
  def test_accepts_script_free_artifacts_for_both_profiles
    %w[explainer ui-mock].each do |profile|
      assert HtmlArtifacts::Validator.new(minimal_html, profile: profile).validate!
    end
  end

  def test_accepts_hashed_renderer_script_for_explainer
    script = "document.querySelectorAll('[data-item]').forEach((item) => item.hidden = false);"
    hash = Base64.strict_encode64(Digest::SHA256.digest(script))
    html = minimal_html(script: script, script_src: "'sha256-#{hash}'")

    assert HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
  end

  def test_accepts_explicit_inline_script_for_ui_mock
    script = "document.documentElement.dataset.theme = 'dark';"
    html = minimal_html(script: script, script_src: "'unsafe-inline'")

    assert HtmlArtifacts::Validator.new(html, profile: "ui-mock").validate!
  end

  def test_accepts_hashed_inline_script_for_ui_mock
    script = "document.documentElement.dataset.theme = 'dark';"
    hash = Base64.strict_encode64(Digest::SHA256.digest(script))
    html = minimal_html(script: script, script_src: "'sha256-#{hash}'")

    assert HtmlArtifacts::Validator.new(html, profile: "ui-mock").validate!
  end

  def test_accepts_object_properties_named_top_and_parent
    script = "var label = rect.top.toFixed(1) + node.parent.id + app.window.parent.id;"
    html = minimal_html(script: script, script_src: "'unsafe-inline'")

    assert HtmlArtifacts::Validator.new(html, profile: "ui-mock").validate!
  end

  def test_rejects_network_storage_and_unhashed_explainer_script
    script = "fetch('/x'); localStorage.setItem('choice', 'a');"
    html = minimal_html(script: script, script_src: "'unsafe-inline'")

    error = assert_raises(HtmlArtifacts::ValidationError) do
      HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
    end

    assert_includes error.errors, "network API is forbidden"
    assert_includes error.errors, "browser storage is forbidden"
    assert_includes error.errors, "unsafe-inline is forbidden for explainer"
    assert_includes error.errors, "renderer script CSP hash is missing"
  end

  def test_rejects_external_resources_duplicate_ids_and_missing_targets
    body = <<~HTML
      <a href="#missing">missing</a>
      <div id="same"></div>
      <div id="same"></div>
      <script src="https://example.com/app.js"></script>
    HTML
    error = assert_raises(HtmlArtifacts::ValidationError) do
      HtmlArtifacts::Validator.new(minimal_html(body: body), profile: "ui-mock").validate!
    end

    assert_includes error.errors, "external script is forbidden"
    assert_includes error.errors, "duplicate IDs: same"
    assert_includes error.errors, "missing internal anchor targets: missing"
  end

  def test_rejects_parent_browsing_context_access
    ["window.parent.location", "self.top.location", "globalThis['parent'].location", "top.location"].each do |script|
      hash = Base64.strict_encode64(Digest::SHA256.digest(script))
      html = minimal_html(script: script, script_src: "'sha256-#{hash}'")

      error = assert_raises(HtmlArtifacts::ValidationError, script) do
        HtmlArtifacts::Validator.new(html, profile: "explainer").validate!
      end

      assert_includes error.errors, "parent browsing context access is forbidden", script
    end
  end

  def test_rejects_inline_event_handlers
    html = minimal_html(body: '<button type="button" onclick="fetch(\'/x\')">run</button>')

    error = assert_raises(HtmlArtifacts::ValidationError) do
      HtmlArtifacts::Validator.new(html, profile: "ui-mock").validate!
    end

    assert_includes error.errors, "inline event handler is forbidden"
  end

  def test_rejects_image_and_iframe_elements_directly
    html = minimal_html(body: '<img alt="x"><iframe title="x"></iframe>')

    error = assert_raises(HtmlArtifacts::ValidationError) do
      HtmlArtifacts::Validator.new(html, profile: "ui-mock").validate!
    end

    assert_includes error.errors, "image element is forbidden"
    assert_includes error.errors, "iframe element is forbidden"
  end

  def test_cli_reports_success_and_validation_failure
    Dir.mktmpdir("html-artifact-validator-test") do |dir|
      valid_path = File.join(dir, "valid.html")
      invalid_path = File.join(dir, "invalid.html")
      File.write(valid_path, minimal_html, encoding: "UTF-8")
      File.write(invalid_path, "<html></html>", encoding: "UTF-8")

      out = StringIO.new
      assert_equal 0, HtmlArtifacts::CLI.run(["--profile", "explainer", valid_path], out: out, err: StringIO.new)
      assert_includes out.string, "Valid HTML artifact"

      ui_out = StringIO.new
      assert_equal 0, HtmlArtifacts::CLI.run(["--profile", "ui-mock", valid_path], out: ui_out, err: StringIO.new)
      assert_includes ui_out.string, "Valid HTML artifact"

      err = StringIO.new
      assert_equal 2, HtmlArtifacts::CLI.run(["--profile", "explainer", invalid_path], out: StringIO.new, err: err)
      assert_includes err.string, "Validation failed"
    end
  end

  private

  def minimal_html(body: '<main id="content"></main>', script: nil, script_src: "'none'")
    script_html = script ? "<script>#{script}</script>" : ""
    <<~HTML
      <!doctype html>
      <html lang="ja">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta content="default-src 'none'; style-src 'unsafe-inline'; script-src #{script_src}; connect-src 'none'; img-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'" http-equiv="Content-Security-Policy">
        <title>Test</title>
        <style>:focus-visible { outline: 2px solid currentColor; }</style>
      </head>
      <body>#{body}#{script_html}</body>
      </html>
    HTML
  end
end
