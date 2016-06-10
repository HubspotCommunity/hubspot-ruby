module Hubspot
  #
  # HubSpot Engagements API
  #
  class Engagement
    CREATE_ENGAGEMENT_PATH = '/engagements/v1/engagements'

    class << self

      # {http://developers.hubspot.com/docs/methods/engagements/create_engagement}
      def create!(post_data)
        Hubspot::Connection.post_json(CREATE_ENGAGEMENT_PATH, params: {}, body: post_data)
      end

    end
  end
end
