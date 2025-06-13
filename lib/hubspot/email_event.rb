module Hubspot
  class EmailEvent
    EVENTS_PATH = "/email/public/v1/events"
    EVENT_PATH = "/email/public/v1/events/:created/:id"

    attr_reader :app_id, :app_name, :created, :email_campaign_id, :hmid, :id, :location, :portal_id, :recipient, :type,
                :user_agent, :browser, :location, :filtered_event


    def initialize(response_hash)
      @app_id = response_hash["appId"]
      @app_name = response_hash["appName"]
      @created = response_hash["created"]
      @email_campaign_id = response_hash["emailCampaignId"]
      @hmid = response_hash["hmid"]
      @id = response_hash["id"]
      @location = response_hash["location"]
      @portal_id = response_hash["portalId"]
      @recipient = response_hash["recipient"]
      @type = response_hash["type"]

      # User engagement properties
      @user_agent = response_hash["userAgent"]
      @browser = response_hash["browser"]
      @location = response_hash["location"]
      @filtered_event = response_hash["filteredEvent"]
    end

    class << self
      def all(opts = {})
        Hubspot::PagedCollection.new(opts) do |options, offset, limit|
          response = Hubspot::Connection.get_json(
              EVENTS_PATH,
              options.merge("limit" => limit, "offset" => offset)
          )
          events = response["events"].map { |result| new(result) }
          [events, response["offset"], response["hasMore"]]
        end
      end

      def find(created, id)
        response = Hubspot::Connection.get_json(EVENT_PATH, { created: created, id: id })
        new(response)
      end
    end
  end
end