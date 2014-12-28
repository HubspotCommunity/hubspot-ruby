require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Deals API
  #
  # {http://developers.hubspot.com/docs/methods/deals/deals_overview}
  #
  class Deal

    attr_reader :properties
    attr_reader :portal_id
    attr_reader :deal_id
    attr_reader :company_ids
    attr_reader :vids

    CREATE_DEAL_PATH = "/deals/v1/deal"
    GET_DEAL_PATH = "/deals/v1/deal/:deal_id"

    def initialize(response_hash)
      @portal_id = response_hash["portalId"]
      @deal_id = response_hash["dealId"]
      @company_ids = response_hash["associations"]["associatedCompanyIds"]
      @vids = response_hash["associations"]["associatedVids"]
      @properties = Hubspot::Utils.properties_to_hash(response_hash["properties"])
    end

    class << self
      def create!(portal_id, company_ids, vids, params={})
        url = Hubspot::Utils.generate_url(CREATE_DEAL_PATH).concat("&portalId=#{portal_id}")
        associations_hash = {"portalId" => portal_id, "associations" => { "associatedCompanyIds" => company_ids, "associatedVids" => vids}}
        post_data = associations_hash.merge({ properties: Hubspot::Utils.hash_to_properties(params, key_name: "name") })
        resp = HTTParty.post(url, body: post_data.to_json, headers: {"Content-Type" => "application/json"})
        Hubspot::Deal.new(resp.parsed_response)
      end

      def find(deal_id)
        url = Hubspot::Utils.generate_url(GET_DEAL_PATH, {deal_id: deal_id})
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          Hubspot::Deal.new(resp.parsed_response)
        else
          nil
        end
      end
    end
  end
end
