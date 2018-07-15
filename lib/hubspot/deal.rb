require 'hubspot/utils'

module HubSpot
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
      @properties = HubSpot::Utils.properties_to_hash(response_hash["properties"])
    end

    class << self
      def create!(portal_id, company_ids, vids, params={})
        #TODO: clean following hash, HubSpot::Utils should do the trick
        associations_hash = {"portalId" => portal_id, "associations" => { "associatedCompanyIds" => company_ids, "associatedVids" => vids}}
        post_data = associations_hash.merge({ properties: HubSpot::Utils.hash_to_properties(params, key_name: "name") })

        response = HubSpot::Connection.post_json(CREATE_DEAL_PATH, params: {}, body: post_data )
        new(response)
      end

       # Associate a deal with a contact or company
       # {http://developers.hubspot.com/docs/methods/deals/associate_deal}
       # Usage
       # HubSpot::Deal.associate!(45146940, [], [52])
       def associate!(deal_id, company_ids=[], vids=[])
         objecttype = company_ids.any? ? 'COMPANY' : 'CONTACT'
         object_ids = (company_ids.any? ? company_ids : vids).join('&id=')
         HubSpot::Connection.put_json(ASSOCIATE_DEAL_PATH, params: { deal_id: deal_id, OBJECTTYPE: objecttype, objectId: object_ids}, body: {})
       end
 

      def find(deal_id)
        response = HubSpot::Connection.get_json(DEAL_PATH, { deal_id: deal_id })
        new(response)
      end

      # Find recent updated deals.
      # {http://developers.hubspot.com/docs/methods/deals/get_deals_modified}
      # @param count [Integer] the amount of deals to return.
      # @param offset [Integer] pages back through recent contacts.
      def recent(opts = {})
        response = HubSpot::Connection.get_json(RECENT_UPDATED_PATH, opts)
        response['results'].map { |d| new(d) }
      end
      
      # Find all deals associated to a company
      # {http://developers.hubspot.com/docs/methods/deals/get-associated-deals}
      # @param company [HubSpot::Company] the company
      # @return [Array] Array of HubSpot::Deal records
      def find_by_company(company)
        path = ASSOCIATED_DEAL_PATH
        params = { objectType: :company, objectId: company.vid }
        response = HubSpot::Connection.get_json(path, params)
        response["results"].map { |deal_id| find(deal_id) }
      end

    end

    # Archives the contact in hubspot
    # {https://developers.hubspot.com/docs/methods/contacts/delete_contact}
    # @return [TrueClass] true
    def destroy!
      HubSpot::Connection.delete_json(DEAL_PATH, {deal_id: deal_id})
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
    # @return [HubSpot::Deal] self
    def update!(params)
      query = {"properties" => HubSpot::Utils.hash_to_properties(params.stringify_keys!, key_name: 'name')}
      HubSpot::Connection.put_json(UPDATE_DEAL_PATH, params: { deal_id: deal_id }, body: query)
      @properties.merge!(params)
      self
    end
  end
end
