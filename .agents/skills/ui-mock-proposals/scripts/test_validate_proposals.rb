#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require "tmpdir"
require_relative "validate_proposals"

class UiMockProposalValidatorTest < Minitest::Test
  def test_accepts_current_and_three_stable_proposals
    assert UiMockProposals::Validator.new(valid_html).validate!
  end

  def test_rejects_missing_current_mismatched_data_id_and_single_proposal
    html = document(<<~HTML)
      <nav><a href="#proposal-a">A</a></nav>
      <section id="proposal-a" data-proposal-id="wrong"><h2>案A</h2></section>
    HTML

    error = assert_raises(UiMockProposals::ValidationError) do
      UiMockProposals::Validator.new(html).validate!
    end

    assert_includes error.errors, "current baseline anchor is missing"
    assert_includes error.errors, "current baseline navigation link is missing"
    assert_includes error.errors, "must contain 2 to 5 proposals"
    assert_includes error.errors, 'proposal-a must use data-proposal-id="a"'
  end

  def test_rejects_missing_proposal_navigation_link
    html = valid_html.sub('<a href="#proposal-c">C</a>', "")

    error = assert_raises(UiMockProposals::ValidationError) do
      UiMockProposals::Validator.new(html).validate!
    end

    assert_includes error.errors, "navigation link #proposal-c is missing"
  end

  def test_rejects_current_anchor_on_non_content_element
    html = valid_html.sub('<section id="current"><h2>現状</h2></section>', '<div id="current"><h2>現状</h2></div>')

    error = assert_raises(UiMockProposals::ValidationError) do
      UiMockProposals::Validator.new(html).validate!
    end

    assert_includes error.errors, "current baseline anchor is missing"
  end

  def test_cli_validates_file
    Dir.mktmpdir("ui-mock-validator-test") do |dir|
      path = File.join(dir, "proposals.html")
      File.write(path, valid_html, encoding: "UTF-8")
      out = StringIO.new

      assert_equal 0, UiMockProposals::CLI.run([path], out: out, err: StringIO.new)
      assert_includes out.string, "Valid UI proposals"
    end
  end

  private

  def valid_html
    document(<<~HTML)
      <nav>
        <a href="#current">現状</a>
        <a href="#proposal-a">A</a>
        <a href="#proposal-b">B</a>
        <a href="#proposal-c">C</a>
      </nav>
      <section id="current"><h2>現状</h2></section>
      <section id="proposal-a" data-proposal-id="a"><h2>案A</h2></section>
      <section id="proposal-b" data-proposal-id="b"><h2>案B</h2></section>
      <section id="proposal-c" data-proposal-id="c"><h2>案C</h2></section>
    HTML
  end

  def document(body)
    <<~HTML
      <!doctype html>
      <html lang="ja">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'none'; connect-src 'none'; img-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'">
        <title>UI proposals</title>
        <style>:focus-visible { outline: 2px solid currentColor; }</style>
      </head>
      <body>#{body}</body>
      </html>
    HTML
  end
end
