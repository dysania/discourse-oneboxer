require "spec_helper"

describe Onebox::Engine::GithubBlobOnebox do
  let(:link) { "https://github.com/discourse/discourse/blob/master/lib/oneboxer/github_blob_onebox.rb" }
  before do
    fake(link, response("githubblob"))
  end

  it_behaves_like "an engine"

  describe "#to_html" do
    let(:html) { described_class.new(link).to_html }

    it "has raw data" do
      expect(html).to include("oneboxer/handlebars_onebox")
    end

    it "has URL" do
      expect(html).to include(link)
    end
  end
end