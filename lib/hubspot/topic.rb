module Hubspot
  #
  # HubSpot Topics API
  #
  class Topic
    TOPICS_PATH = "/blogs/v3/topics"
    TOPIC_PATH = "/blogs/v3/topics/:topic_id"

    class << self
      # Lists the topics
      # {https://developers.hubspot.com/docs/methods/blogv2/get_topics)
      # @return [Hubspot::Topic] array of topics
      def list
        response = Hubspot::Connection.get_json(TOPICS_PATH, {})
        response['objects'].map { |t| new(t) }
      end

      # Finds the details for a specific topic_id
      # {https://developers.hubspot.com/docs/methods/blogv2/get_topics_topic_id }
      # @return Hubspot::Topic
      def find_by_topic_id(id)
        response = Hubspot::Connection.get_json(TOPIC_PATH, { topic_id: id })
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
  end
end
