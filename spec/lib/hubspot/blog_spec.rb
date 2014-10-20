require 'spec_helper'
require 'timecop'

describe Hubspot::Blog do
  before do
    Hubspot.configure(hapikey: "demo")
    Timecop.freeze(Time.local(2012, 'Oct', 10))
  end

  after do
    Timecop.return
  end

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
    cassette "one_month_blog_posts_filter_state"
    let(:blog) { Hubspot::Blog.new(example_blog_hash) }

    describe "can be filtered by state" do

      it "should filter the posts to published by default" do
        # in our date range they are all draft, hence no items
        blog.posts.length.should be(13)
      end

      it "should validate the state is a valid one" do
        expect { blog.posts('invalid') }.to raise_error(Hubspot::Blog::InvalidParams)
      end

      it "should allow draft posts if specified" do
        # in our date range they are all draft, hence no item
        blog.posts({ state: false }).length.should be > 0
      end
    end

    describe "can be ordered" do
      it "created at descending is default" do
        # in our date range they are all draft, hence no item
        created_timestamps = blog.posts.map { |post| post['created'] }
        expect(created_timestamps.sort.reverse).to eq(created_timestamps)
      end

      it "by created ascending" do
        # in our date range they are all draft, hence no item
        created_timestamps = blog.posts({order_by: '+created'}).map { |post| post['created'] }
        expect(created_timestamps.sort).to eq(created_timestamps)
      end
    end
    it "should find the most recent posts" do
      # doesn't seem to be much of an upper limit to the number
      # of posts you can request.  In testing against the DEMO
      # api you can request 200 blog posts (and you get them!)
      #
      # So, to get the most recent posts I think it best to
      # page in chunks of 20, and just keep on iterating from
      # the last page down until we get the number of published
      # posts we want, or hit rock bottom.
      #
      # Perhaps taking a larger amount (as the API is responsive
      # and ideally we would be caching this somewhere clientside
      # and doing it as a background job) would make the procedure
      # a bit simpler
    end
  end
end
