require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contacts API
  #
  # {https://developers.hubspot.com/docs/endpoints#contacts-api}
  #
  class Blog
    class InvalidParams < StandardError
    end

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


    # defaults to returning the last 2 months worth of published blog posts
    # in date descending order (i.e. most recent first)
    def posts(params = {})
      default_params = {
        content_group_id: self["id"],
        order_by: '-created',
        created__gt: Time.now - 2.month,
        state: 'PUBLISHED'
      }
      raise InvalidParams.new('params must be passed as a hash') unless params.is_a?(Hash)
      params = default_params.merge(params)
      raise InvalidParams.new('State parameter was invalid') unless [false, 'PUBLISHED', 'DRAFT'].include?(params[:state])
      params.delete(:state) if params[:state] == false

      url = Hubspot::Utils.generate_url(BLOG_POSTS_PATH, params)
      puts url
      resp = HTTParty.get(url, format: :json)
      if resp.success?
        blog_post_objects = resp.parsed_response['objects']
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
