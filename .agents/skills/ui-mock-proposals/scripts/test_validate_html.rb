#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "minitest/autorun"
require_relative "validate_html"

class UiMockHtmlValidatorTest < Minitest::Test
  def test_accepts_script_free_html
    assert UiMockHtml::Validator.new(minimal_html).validate!
  end

  def test_accepts_explicit_inline_script_for_ui_mock
    script = "document.documentElement.dataset.theme = 'dark';"
    html = minimal_html(script: script, script_src: "'unsafe-inline'")

    assert UiMockHtml::Validator.new(html).validate!
  end

  def test_accepts_hashed_inline_script_for_ui_mock
    script = "document.documentElement.dataset.theme = 'dark';"
    hash = [Digest::SHA256.digest(script)].pack("m0")
    html = minimal_html(script: script, script_src: "'sha256-#{hash}'")

    assert UiMockHtml::Validator.new(html).validate!
  end

  def test_accepts_object_properties_named_top_and_parent
    script = "var label = rect.top.toFixed(1) + node.parent.id + app.window.parent.id;"
    html = minimal_html(script: script, script_src: "'unsafe-inline'")

    assert UiMockHtml::Validator.new(html).validate!
  end

  def test_rejects_network_and_storage
    script = "fetch('/x'); localStorage.setItem('choice', 'a');"
    html = minimal_html(script: script, script_src: "'unsafe-inline'")

    error = assert_raises(UiMockHtml::ValidationError) do
      UiMockHtml::Validator.new(html).validate!
    end

    assert_includes error.errors, "network API is forbidden"
    assert_includes error.errors, "browser storage is forbidden"
  end

  def test_rejects_external_resources_duplicate_ids_and_missing_targets
    body = <<~HTML
      <a href="#missing">missing</a>
      <div id="same"></div>
      <div id="same"></div>
      <script src="https://example.com/app.js"></script>
    HTML
    error = assert_raises(UiMockHtml::ValidationError) do
      UiMockHtml::Validator.new(minimal_html(body: body)).validate!
    end

    assert_includes error.errors, "external script is forbidden"
    assert_includes error.errors, "duplicate IDs: same"
    assert_includes error.errors, "missing internal anchor targets: missing"
  end

  def test_rejects_non_portable_references
    body = <<~HTML
      <a href="/Users/private-user/report.md">absolute</a>
      <a href="file:///tmp/report.md">file</a>
      <form action="C:\\Users\\user\\submit"></form>
    HTML
    error = assert_raises(UiMockHtml::ValidationError) do
      UiMockHtml::Validator.new(minimal_html(body: body)).validate!
    end

    assert error.errors.any? { |item| item.include?("non-portable references are forbidden") }
  end

  def test_rejects_parent_browsing_context_access
    ["window.parent.location", "self.top.location", "globalThis['parent'].location", "top.location"].each do |script|
      hash = [Digest::SHA256.digest(script)].pack("m0")
      html = minimal_html(script: script, script_src: "'sha256-#{hash}'")

      error = assert_raises(UiMockHtml::ValidationError, script) do
        UiMockHtml::Validator.new(html).validate!
      end

      assert_includes error.errors, "parent browsing context access is forbidden", script
    end
  end

  def test_rejects_inline_event_handlers
    html = minimal_html(body: '<button type="button" onclick="fetch(\'/x\')">run</button>')

    error = assert_raises(UiMockHtml::ValidationError) do
      UiMockHtml::Validator.new(html).validate!
    end

    assert_includes error.errors, "inline event handler is forbidden"
  end

  def test_rejects_image_and_iframe_elements_directly
    html = minimal_html(body: '<img alt="x"><iframe title="x"></iframe>')

    error = assert_raises(UiMockHtml::ValidationError) do
      UiMockHtml::Validator.new(html).validate!
    end

    assert_includes error.errors, "image element is forbidden"
    assert_includes error.errors, "iframe element is forbidden"
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
