# frozen_string_literal: true

require "rspec"
require "pry"
require "fakeweb"
require "onebox"
require 'mocha/api'

require_relative "support/html_spec_helper"

module FakeWeb
  # Monkey-patch fakeweb to support Ruby 2.4+.
  # See https://github.com/chrisk/fakeweb/pull/59.
  class StubSocket
    def close; end
  end

  # Monkey-patch to use Addressable::URI (rather than URI) to parse uris
  class Registry
    def normalize_uri(uri)
      return uri if uri.is_a?(Regexp)
      normalized_uri =
        case uri
        when URI then uri
        when String
          uri = 'http://' + uri unless uri.match('^https?://')
          URI.parse(Addressable::URI.parse(uri).normalize.to_s)
        end
      normalized_uri.query = sort_query_params(normalized_uri.query)
      normalized_uri.normalize
    end
  end
end

RSpec.configure do |config|
  config.before(:all) do
    FakeWeb.allow_net_connect = false
  end
  config.include HTMLSpecHelper
end

shared_context "engines" do
  before(:each) do
    fixture = defined?(@onebox_fixture) ? @onebox_fixture : described_class.onebox_name
    fake(defined?(@uri) ? @uri : @link, response(fixture))
    @onebox = described_class.new(@link)
    @html = @onebox.to_html
    @data = Onebox::Helpers.symbolize_keys(@onebox.send(:data))
  end

  let(:onebox) { @onebox }
  let(:html) { @html }
  let(:data) { @data }
  let(:link) { @link }
end

shared_examples_for "an engine" do
  it "responds to data" do
    expect(described_class.private_instance_methods).to include(:data)
  end

  it "correctly matches the url" do
    onebox = Onebox::Matcher.new(link, { allowed_iframe_regexes: [/.*/] }).oneboxed
    expect(onebox).to be(described_class)
  end

  describe "#data" do
    it "includes title" do
      expect(data[:title]).not_to be_nil
    end

    it "includes link" do
      expect(data[:link]).not_to be_nil
    end

    it "is serializable" do
      expect { Marshal.dump(data) }.to_not raise_error
    end
  end
end

shared_examples_for "a layout engine" do
  describe "#to_html" do
    it "includes subname" do
      expect(html).to include(%|<aside class="onebox #{described_class.onebox_name}">|)
    end

    it "includes title" do
      expect(html).to include(data[:title])
    end

    it "includes link" do
      expect(html).to include(%|class="link" href="#{data[:link]}|)
    end

    it "includes badge" do
      expect(html).to include(%|<strong class="name">#{data[:badge]}</strong>|)
    end

    it "includes domain" do
      expect(html).to include(%|class="domain" href="#{data[:domain]}|)
    end
  end
end
