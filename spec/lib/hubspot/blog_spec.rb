require 'timecop'

describe Hubspot do
  let(:example_blog_hash) do
    VCR.use_cassette("blog_list", record: :none) do
      url = Hubspot::Connection.send(:generate_url, Hubspot::Blog::BLOG_LIST_PATH)
      resp = HTTParty.get(url, format: :json)
      resp.parsed_response["objects"].first
    end
  end
  let(:created_range_params) { { created__gt: false, created__range: (Time.now..Time.now + 2.years)  } }

  before do
    Hubspot.configure(hapikey: "demo")
    Timecop.freeze(Time.local(2012, 'Oct', 10))
  end

  after do
    Timecop.return
  end

  describe Hubspot::Blog do

    describe ".list" do
      cassette "blog_list"
      let(:blog_list) { Hubspot::Blog.list }

      it "should have a list of blogs" do
        blog_list.count.should be(1)
      end
    end

    describe ".find_by_id" do
      cassette "blog_list"

      it "should have a list of blogs" do
        blog = Hubspot::Blog.find_by_id(351076997)
        blog["id"].should eq(351076997)
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
          pending 'This test does not pass reliably'
          blog.posts.length.should be(14)
        end

        it "should validate the state is a valid one" do
          expect { blog.posts('invalid') }.to raise_error(Hubspot::InvalidParams)
        end

        it "should allow draft posts if specified" do
          blog.posts({ state: false }.merge(created_range_params)).length.should be > 0
        end
      end

      describe "can be ordered" do
        it "created at descending is default" do
          created_timestamps = blog.posts(created_range_params).map { |post| post['created'] }
          expect(created_timestamps.sort.reverse).to eq(created_timestamps)
        end

        it "by created ascending" do
          pending
          created_timestamps = blog.posts({order_by: '+created'}.merge(created_range_params)).map { |post| post['created'] }
          expect(created_timestamps.sort).to eq(created_timestamps)
        end
      end

      it "can set a page size" do
        pending 'Not working'
        blog.posts({limit: 10}.merge(created_range_params)).length.should be(10)
      end
    end
  end

  describe Hubspot::BlogPost do
    cassette "blog_posts"

    let(:example_blog_post) do
      VCR.use_cassette("one_month_blog_posts_filter_state", record: :none) do
        blog = Hubspot::Blog.new(example_blog_hash)
        blog.posts(created_range_params).first
      end
    end

    it "should have a created_at value specific method" do
      expect(example_blog_post.created_at).to eq(Time.at(example_blog_post['created'] / 1000))
    end

    it "can find by blog_post_id" do
      blog = Hubspot::BlogPost.find_by_blog_post_id(422192866)
      expect(blog['id']).to eq(422192866)
    end

    context 'containing a topic' do
      # 422192866 contains a topic
      let(:blog_with_topic) { Hubspot::BlogPost.find_by_blog_post_id(422192866) }

      it "should return topic objects" do
        expect(blog_with_topic.topics.first.is_a?(Hubspot::Topic)).to be(true)
      end
    end
  end
end
