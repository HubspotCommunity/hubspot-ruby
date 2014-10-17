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
  end
end
