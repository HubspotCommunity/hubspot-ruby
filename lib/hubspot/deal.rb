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
    DEAL_PATH = "/deals/v1/deal/:deal_id"
    RECENT_UPDATED_PATH = "/deals/v1/deal/recent/modified"

    def initialize(response_hash)
      @portal_id = response_hash["portalId"]
      @deal_id = response_hash["dealId"]
      @company_ids = response_hash["associations"]["associatedCompanyIds"]
      @vids = response_hash["associations"]["associatedVids"]
      @properties = Hubspot::Utils.properties_to_hash(response_hash["properties"])
    end

    class << self
      # Creates a deal in hubspot
      # @raise [Hubspot::RequestError] if the response isn't a success
      # @return [Hubspot::Deal] the created deal
      def create!(portal_id, company_ids, vids, params={})
        url = Hubspot::Utils.generate_url(CREATE_DEAL_PATH).concat("&portalId=#{portal_id}")
        associations_hash = {"portalId" => portal_id, "associations" => { "associatedCompanyIds" => company_ids, "associatedVids" => vids}}
        post_data = associations_hash.merge({ properties: Hubspot::Utils.hash_to_properties(params, key_name: "name") })
        resp = HTTParty.post(url, body: post_data.to_json, headers: {"Content-Type" => "application/json"})
        raise(Hubspot::RequestError.new(resp, "Could not create deal.")) unless resp.success?
        Hubspot::Deal.new(resp.parsed_response)
      end

      def update!(deal_id, params)
        url = Hubspot::Utils.generate_url(DEAL_PATH, deal_id: deal_id)
        post_data = { properties: Hubspot::Utils.hash_to_properties(params, key_name: "name") }
        resp = HTTParty.put(url, body: post_data.to_json, headers: {"Content-Type" => "application/json"})
        raise(Hubspot::RequestError.new(resp, "Could not update deal.")) unless resp.success?
        new(resp.parsed_response)
      end

      def find(deal_id)
        url = Hubspot::Utils.generate_url(DEAL_PATH, {deal_id: deal_id})
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          Hubspot::Deal.new(resp.parsed_response)
        else
          nil
        end
      end

      # Find recent updated deals.
      # {http://developers.hubspot.com/docs/methods/deals/get_deals_modified}
      # @param count [Integer] the amount of deals to return.
      # @param offset [Integer] pages back through recent contacts.
      def recent(opts = {})
        url = Hubspot::Utils.generate_url(RECENT_UPDATED_PATH, opts)
        request = HTTParty.get(url, format: :json)

        raise(Hubspot::RequestError.new(request)) unless request.success?

        found = request.parsed_response['results']
        return found.map{|h| new(h) }
      end
    end

    def update!(params={})
      self.class.update! self.deal_id, params
    end

    # Archives the contact in hubspot
    # {https://developers.hubspot.com/docs/methods/contacts/delete_contact}
    # @return [TrueClass] true
    def destroy!
      url = Hubspot::Utils.generate_url(DEAL_PATH, {deal_id: deal_id})
      request = HTTParty.delete(url, format: :json)
      raise(Hubspot::RequestError.new(request)) unless request.success?
      @destroyed = true
    end

    def destroyed?
      !!@destroyed
    end
  end
end
