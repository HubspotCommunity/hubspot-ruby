require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Topics API
  #
  class Topic
    TOPIC_LIST_PATH = "/content/api/v2/topics"
    GET_TOPIC_BY_ID_PATH = "/content/api/v2/topics/:topic_id"

    class << self
      # Lists the topics
      # {https://developers.hubspot.com/docs/methods/blogv2/get_topics)
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

      # Finds the details for a specific topic_id
      # {https://developers.hubspot.com/docs/methods/blogv2/get_topics_topic_id }
      # @return Hubspot::Topic or nil

      def find_by_topic_id(id)
        url = Hubspot::Utils.generate_url(GET_TOPIC_BY_ID_PATH, topic_id: id)
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          Topic.new(resp.parsed_response)
        else
          nil
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
