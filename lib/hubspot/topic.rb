require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contacts API
  #
  # {https://developers.hubspot.com/docs/endpoints#contacts-api}
  #
  class Topic
    TOPIC_LIST_PATH = "/content/api/v2/topics"

    class << self
      # Lists the topics
      # {https://developers.hubspot.com/docs/methods/blogv2/get_blogs}
      # No param filtering is currently implemented
      # @return [Hubspot::Topic, []] array of topics or empty_array
      def list
        url = Hubspot::Utils.generate_url(TOPIC_LIST_PATH)
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          resp.parsed_response['objects'].map do |topic_hash|
            Topic.new(topic_hash)
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
