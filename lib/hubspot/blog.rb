require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contacts API
  #
  # {https://developers.hubspot.com/docs/endpoints#contacts-api}
  #
  class Blog
    BLOG_LIST_PATH = "/content/api/v2/blogs"
    BLOG_POSTS_PATH = "/content/api/v2/blog-posts"

    class << self
      # Lists the blogs
      # {https://developers.hubspot.com/docs/methods/blogv2/get_blogs}
      # No param filtering is currently implemented
      # @return [Hubspot::Blog, []] the first 20 blogs or empty_array
      def list
        url = Hubspot::Utils.generate_url(BLOG_LIST_PATH)
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          resp.parsed_response['objects'].map do |blog_hash|
            Blog.new(blog_hash)
          end
        else
          []
        end
      end
    end

    attr_reader :properties

    def initialize(response_hash)
      @properties = response_hash #no need to parse anything, we have properties
    end

    def [](property)
      @properties[property]
    end

    def posts(allow_drafts = false)
      url = Hubspot::Utils.generate_url(BLOG_POSTS_PATH, content_group_id: self["id"], created__gt: Time.now - 1.month )
      puts url
      resp = HTTParty.get(url, format: :json)
      if resp.success?
        blog_post_objects = resp.parsed_response['objects']
        blog_post_objects.reject! { |blog_post| blog_post["is_draft"] } unless allow_drafts
        blog_post_objects.map do |blog_post_hash|
          BlogPost.new(blog_post_hash)
        end
      else
        []
      end
    end
  end

  class BlogPost
    def initialize(response_hash)
      @properties = response_hash #no need to parse anything, we have properties
    end

    def [](property)
      @properties[property]
    end
  end
end
