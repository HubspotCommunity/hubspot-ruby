module Hubspot
  #
  # HubSpot Contacts API
  #
  class Blog
    BLOG_LIST_PATH = "/content/api/v2/blogs"
    BLOG_POSTS_PATH = "/content/api/v2/blog-posts"
    GET_BLOG_BY_ID_PATH = "/content/api/v2/blogs/:blog_id"

    class << self
      # Lists the blogs
      # {https://developers.hubspot.com/docs/methods/blogv2/get_blogs}
      # No param filtering is currently implemented
      # @return [Hubspot::Blog] the first 20 blogs or empty_array
      def list
        response = Hubspot::Connection.get_json(BLOG_LIST_PATH, {})
        response['objects'].map { |b| new(b) }
      end

      # Finds a specific blog by its ID
      # {https://developers.hubspot.com/docs/methods/blogv2/get_blogs_blog_id}
      # @return Hubspot::Blog
      def find_by_id(id)
        response = Hubspot::Connection.get_json(GET_BLOG_BY_ID_PATH, { blog_id: id })
        new(response)
      end
    end

    attr_reader :properties

    def initialize(response_hash)
      @properties = response_hash #no need to parse anything, we have properties
    end

    def [](property)
      @properties[property]
    end


    # Returns the posts for this blog instance.
    #   defaults to returning the last 2 months worth of published blog posts
    #   in date descending order (i.e. most recent first)
    # {https://developers.hubspot.com/docs/methods/blogv2/get_blog_posts}
    # @return [Hubspot::BlogPost]
    def posts(params = {})
      default_params = {
        content_group_id: self["id"],
        order_by: '-created',
        created__gt: Time.now - 2.month,
        state: 'PUBLISHED'
      }
      raise Hubspot::InvalidParams.new('params must be passed as a hash') unless params.is_a?(Hash)
      params = default_params.merge(params)

      raise Hubspot::InvalidParams.new('State parameter was invalid') unless [false, 'PUBLISHED', 'DRAFT'].include?(params[:state])
      params.each { |k, v| params.delete(k) if v == false }

      response = Hubspot::Connection.get_json(BLOG_POSTS_PATH, params)
      response['objects'].map { |p| BlogPost.new(p) }
    end
  end

  class BlogPost
    GET_BLOG_POST_BY_ID_PATH = "/content/api/v2/blog-posts/:blog_post_id"

    # Returns a specific blog post by ID
    # {https://developers.hubspot.com/docs/methods/blogv2/get_blog_posts_blog_post_id}
    # @return Hubspot::BlogPost
    def self.find_by_blog_post_id(id)
      response = Hubspot::Connection.get_json(GET_BLOG_POST_BY_ID_PATH, { blog_post_id: id })
      new(response)
    end

    def initialize(response_hash)
      @properties = response_hash #no need to parse anything, we have properties
    end

    def [](property)
      @properties[property]
    end

    def created_at
      Time.at(@properties['created'] / 1000)
    end

    def topics
      @topics ||= begin
        if @properties['topic_ids'].empty?
          []
        else
          @properties['topic_ids'].map do |topic_id|
            Hubspot::Topic.find_by_topic_id(topic_id)
          end
        end
      end
    end
  end
end
