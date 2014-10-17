require 'spec_helper'

describe Hubspot::Blog do
  before { Hubspot.configure(hapikey: "demo") }

  let(:example_blog_hash) do
    VCR.use_cassette("blog_list", record: :none) do
      url = Hubspot::Utils.generate_url(Hubspot::Blog::BLOG_LIST_PATH)
      resp = HTTParty.get(url, format: :json)
      resp.parsed_response["objects"].first
    end
  end

  describe ".list" do
    cassette "blog_list"
    let(:blog_list) { Hubspot::Blog.list }

    it "should have a list of blogs" do
      blog_list.count.should be(1)
    end
  end

  describe "#initialize" do
    subject{ Hubspot::Blog.new(example_blog_hash) }
    its(["name"]) { should == "API Demonstration Blog" }
    its(["id"])   { should == 351076997 }
  end

  describe "#posts" do
    let(:blog) { Hubspot::Blog.new(example_blog_hash) }
    cassette "one_month_blog_posts_list"

    it "should filter the posts to published by default" do
      blog.posts.length.should be(0)
    end
  end
end
