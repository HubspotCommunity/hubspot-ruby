require 'hubspot/utils'

module Hubspot
  #
  # HubSpot Deals API
  #
  # {http://developers.hubspot.com/docs/methods/deals/deals_overview}
  #
  class Deal
    CREATE_DEAL_PATH = "/deals/v1/deal"
    DEAL_PATH = "/deals/v1/deal/:deal_id"
    RECENT_UPDATED_PATH = "/deals/v1/deal/recent/modified"
    UPDATE_DEAL_PATH = '/deals/v1/deal/:deal_id'
    ASSOCIATE_DEAL_PATH = '/deals/v1/deal/:deal_id/associations/:OBJECTTYPE?id=:objectId'
    ASSOCIATED_DEAL_PATH = "/deals/v1/deal/associated/:objectType/:objectId"

    attr_reader :properties
    attr_reader :portal_id
    attr_reader :deal_id
    attr_reader :company_ids
    attr_reader :vids

    def initialize(response_hash)
      @portal_id = response_hash["portalId"]
      @deal_id = response_hash["dealId"]
      @company_ids = response_hash["associations"]["associatedCompanyIds"]
      @vids = response_hash["associations"]["associatedVids"]
      @properties = Hubspot::Utils.properties_to_hash(response_hash["properties"])
    end

    class << self
      def create!(portal_id, company_ids, vids, params={})
        #TODO: clean following hash, Hubspot::Utils should do the trick
        associations_hash = {"portalId" => portal_id, "associations" => { "associatedCompanyIds" => company_ids, "associatedVids" => vids}}
        post_data = associations_hash.merge({ properties: Hubspot::Utils.hash_to_properties(params, key_name: "name") })

        response = Hubspot::Connection.post_json(CREATE_DEAL_PATH, params: {}, body: post_data )
        new(response)
      end

      # Associate a deal with contacts and/or companies
      # {http://developers.hubspot.com/docs/methods/deals/associate_deal}
      # Can make up to two API calls, one per object type.
      # Usage
      #   Hubspot::Deal.associate!(45146940, [], [52])
      def associate!(deal_id, company_ids=[], vids=[])
        associate(deal_id, 'CONTACT', vids) if vids.any?
        associate(deal_id, 'COMPANY', company_ids) if company_ids.any?
      end

      def find(deal_id)
        response = Hubspot::Connection.get_json(DEAL_PATH, { deal_id: deal_id })
        new(response)
      end

      # Find recent updated deals.
      # {http://developers.hubspot.com/docs/methods/deals/get_deals_modified}
      # @param count [Integer] the amount of deals to return.
      # @param offset [Integer] pages back through recent contacts.
      def recent(opts = {})
        response = Hubspot::Connection.get_json(RECENT_UPDATED_PATH, opts)
        response['results'].map { |d| new(d) }
      end

      # Find all deals associated to a company
      # {http://developers.hubspot.com/docs/methods/deals/get-associated-deals}
      # @param company [Hubspot::Company] the company
      # @return [Array] Array of Hubspot::Deal records
      def find_by_company(company)
        path = ASSOCIATED_DEAL_PATH
        params = { objectType: :company, objectId: company.vid }
        response = Hubspot::Connection.get_json(path, params)
        response["results"].map { |deal_id| find(deal_id) }
      end

      private

      def associate(deal_id, object_type, ids)
        Hubspot::Connection.put_json(
          ASSOCIATE_DEAL_PATH,
          params: { deal_id: deal_id, OBJECTTYPE: object_type, objectId: ids.join('&id=') },
          body: {}
        )
      end
    end

    # Archives the contact in hubspot
    # {https://developers.hubspot.com/docs/methods/contacts/delete_contact}
    # @return [TrueClass] true
    def destroy!
      Hubspot::Connection.delete_json(DEAL_PATH, {deal_id: deal_id})
      @destroyed = true
    end

    def destroyed?
      !!@destroyed
    end

    def [](property)
      @properties[property]
    end

    # Updates the properties of a deal
    # {https://developers.hubspot.com/docs/methods/deals/update_deal}
    # @param params [Hash] hash of properties to update
    # @return [Hubspot::Deal] self
    def update!(params)
      query = {"properties" => Hubspot::Utils.hash_to_properties(params.stringify_keys!, key_name: 'name')}
      Hubspot::Connection.put_json(UPDATE_DEAL_PATH, params: { deal_id: deal_id }, body: query)
      @properties.merge!(params)
      self
    end
  end
end
