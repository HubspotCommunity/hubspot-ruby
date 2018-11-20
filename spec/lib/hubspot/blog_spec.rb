require 'timecop'

describe Hubspot do
  before do
    Hubspot.configure(hapikey: "demo")
    Timecop.freeze(Time.utc(2012, 'Oct', 10))
  end

  after do
    Timecop.return
  end

  describe Hubspot::Blog do
    describe ".list" do
      it "returns a list of blogs" do
        VCR.use_cassette("blog_list") do
          result = Hubspot::Blog.list

          assert_requested :get, hubspot_api_url("/content/api/v2/blogs?hapikey=demo")
          expect(result).to be_kind_of(Array)
          expect(result.first).to be_a(Hubspot::Blog)
        end
      end
    end

    describe ".find_by_id" do
      it "retrieves a blog by id" do
        VCR.use_cassette("blog_list") do
          id = 351076997
          result = Hubspot::Blog.find_by_id(id)

          assert_requested :get, hubspot_api_url("/content/api/v2/blogs/#{id}?hapikey=demo")
          expect(result).to be_a(Hubspot::Blog)
        end
      end
    end

    describe "#[]" do
      it "returns the value for the given key" do
        data = {
          "id" => 123,
          "name" => "Demo",
        }
        blog = Hubspot::Blog.new(data)

        expect(blog["id"]).to eq(data["id"])
        expect(blog["name"]).to eq(data["name"])
      end

      context "when the value is unknown" do
        it "returns nil" do
          blog = Hubspot::Blog.new({})

          expect(blog["nope"]).to be_nil
        end
      end
    end

    describe "#posts" do
      it "returns published blog posts created in the last 2 months" do
        VCR.use_cassette("blog_posts/all_blog_posts") do
          blog_id = 123
          created_gt = timestamp_in_milliseconds(Time.now - 2.months)
          blog = Hubspot::Blog.new({ "id" => blog_id })

          result = blog.posts

          assert_requested :get, hubspot_api_url("/content/api/v2/blog-posts?content_group_id=#{blog_id}&created__gt=#{created_gt}&hapikey=demo&order_by=-created&state=PUBLISHED")
          expect(result).to be_kind_of(Array)
        end
      end

      it "includes given parameters in the request" do
        VCR.use_cassette("blog_posts/filter_blog_posts") do
          blog_id = 123
          created_gt = timestamp_in_milliseconds(Time.now - 2.months)
          blog = Hubspot::Blog.new({ "id" => 123 })

          result = blog.posts({ state: "DRAFT" })

          assert_requested :get, hubspot_api_url("/content/api/v2/blog-posts?content_group_id=#{blog_id}&created__gt=#{created_gt}&hapikey=demo&order_by=-created&state=DRAFT")
          expect(result).to be_kind_of(Array)
        end
      end

      it "raises when given an unknown state" do
        blog = Hubspot::Blog.new({})

        expect {
          blog.posts({ state: "unknown" })
        }.to raise_error(Hubspot::InvalidParams, "State parameter was invalid")
      end
    end
  end

  describe Hubspot::BlogPost do
    describe "#created_at" do
      it "returns the created timestamp as a Time" do
        timestamp = timestamp_in_milliseconds(Time.now)
        blog_post = Hubspot::BlogPost.new({ "created" => timestamp })

        expect(blog_post.created_at).to eq(Time.at(timestamp/1000))
      end
    end

    describe ".find_by_blog_post_id" do
      it "retrieves a blog post by id" do
        VCR.use_cassette "blog_posts" do
          blog_post_id = 422192866

          result = Hubspot::BlogPost.find_by_blog_post_id(blog_post_id)

          assert_requested :get, hubspot_api_url("/content/api/v2/blog-posts/#{blog_post_id}?hapikey=demo")
          expect(result).to be_a(Hubspot::BlogPost)
        end
      end
    end

    describe "#topics" do
      it "returns the list of topics" do
        VCR.use_cassette "blog_posts" do
          blog_post = Hubspot::BlogPost.find_by_blog_post_id(422192866)

          topics = blog_post.topics

          expect(topics).to be_kind_of(Array)
          expect(topics.first).to be_a(Hubspot::Topic)
        end
      end

      context "when the blog post does not have topics" do
        it "returns an empty list" do
          blog_post = Hubspot::BlogPost.new({ "topic_ids" => [] })

          topics = blog_post.topics

          expect(topics).to be_empty
        end
      end
    end
  end

  def hubspot_api_url(path)
    URI.join(Hubspot::Config.base_url, path)
  end

  def timestamp_in_milliseconds(time)
    time.to_i * 1000
  end
end
