module Hubspot
  class Campaign
    CAMPAIGNS_PATH = "/email/public/v1/campaigns" #https://api.hubapi.com/email/public/v1/campaigns?hapikey=demo&limit=3
    CAMPAIGNS_BY_ID_PATH = "/email/public/v1/campaigns/by-id" #example: https://api.hubapi.com/email/public/v1/campaigns/by-id?hapikey=demo&limit=3
    CAMPAIGN_PATH = "/email/public/v1/campaigns/:campaign_id"

    attr_reader :id, :name, :app_id, :app_name, :last_updated_time, :content_id, :counters, :num_included, :num_queued,
                :sub_type, :subject, :type

    def initialize(response_hash)
      @id = response_hash["id"]
      @name = response_hash["name"]
      @app_id = response_hash["appId"]
      @app_name = response_hash["appName"]
      @content_id = response_hash["contentId"]
      @counters = response_hash["counters"]
      @num_included = response_hash["numIncluded"]
      @num_queued = response_hash["numQueued"]
      @sub_type = response_hash["subType"]
      @subject = response_hash["subject"]
      @type = response_hash["type"]
      @last_updated_time = response["lastUpdatedTime"]
    end

    class << self
      def all(opts = {})
        Hubspot::PagedCollection.new(opts) do |options, offset, limit|
          response = Hubspot::Connection.get_json(
              CAMPAIGNS_PATH,
              options.merge("limit" => limit, "offset" => offset)
          )
          campaigns = response["campaigns"].map { |result| new(result) }
          [campaigns, response["offset"], response["hasMore"]]
        end
      end

      def all_by_id(opts = {})
        Hubspot::PagedCollection.new(opts) do |options, offset, limit|
          response = Hubspot::Connection.get_json(
              CAMPAIGNS_BY_ID_PATH,
              options.merge("limit" => limit, "offset" => offset)
          )
          campaigns = response["campaigns"].map { |result| new(result) }
          [campaigns, response["offset"], response["hasMore"]]
        end
      end

      def find(id)
        response = Hubspot::Connection.get_json(CAMPAIGN_PATH, { campaign_id: id })
        new(response)
      end

    end
  end
end