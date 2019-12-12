require 'hubspot/utils'

module Hubspot
  #
  # HubSpot Deals API
  #
  # {http://developers.hubspot.com/docs/methods/deals/deals_overview}
  #
  class Deal
    ALL_DEALS_PATH = "/deals/v1/deal/paged"
    CREATE_DEAL_PATH = "/deals/v1/deal"
    DEAL_PATH = "/deals/v1/deal/:deal_id"
    RECENT_UPDATED_PATH = "/deals/v1/deal/recent/modified"
    UPDATE_DEAL_PATH = '/deals/v1/deal/:deal_id'

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

      # Updates the properties of a deal
      # {http://developers.hubspot.com/docs/methods/deals/update_deal}
      # @param deal_id [Integer] hubspot deal_id
      # @param params [Hash] hash of properties to update
      # @return [boolean] success
      def update(id, properties = {})
        update!(id, properties)
      rescue Hubspot::RequestError => e
        false
      end

      # Updates the properties of a deal
      # {http://developers.hubspot.com/docs/methods/deals/update_deal}
      # @param deal_id [Integer] hubspot deal_id
      # @param params [Hash] hash of properties to update
      # @return [Hubspot::Deal] Deal record
      def update!(id, properties = {})
        request = { properties: Hubspot::Utils.hash_to_properties(properties.stringify_keys, key_name: 'name') }
        response = Hubspot::Connection.put_json(UPDATE_DEAL_PATH, params: { deal_id: id, no_parse: true }, body: request)
        response.success?
      end

      # Associate a deal with a contact or company
      # {http://developers.hubspot.com/docs/methods/deals/associate_deal}
      # Usage
      # Hubspot::Deal.associate!(45146940, [32], [52])
      def associate!(deal_id, company_ids=[], vids=[])
        associations = company_ids.map do |id|
          { from_id: deal_id, to_id: id, definition_id: Hubspot::Association::DEAL_TO_COMPANY }
        end
        associations += vids.map do |id|
          { from_id: deal_id, to_id: id, definition_id: Hubspot::Association::DEAL_TO_CONTACT }
        end
        Hubspot::Association.batch_create(associations)
      end
      
      def find(deal_id)
        response = Hubspot::Connection.get_json(DEAL_PATH, { deal_id: deal_id })
        new(response)
      end

      def all(opts = {})
        path = ALL_DEALS_PATH

        opts[:includeAssociations] = true # Needed for initialize to work
        response = Hubspot::Connection.get_json(path, opts)

        result = {}
        result['deals'] = response['deals'].map { |d| new(d) }
        result['offset'] = response['offset']
        result['hasMore'] = response['hasMore']
        return result
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
        find_by_association company
      end

      # Find all deals associated to a contact
      # {http://developers.hubspot.com/docs/methods/deals/get-associated-deals}
      # @param contact [Hubspot::Contact] the contact
      # @return [Array] Array of Hubspot::Deal records
      def find_by_contact(contact)
        find_by_association contact
      end

      # Find all deals associated to a contact or company
      # @param object [Hubspot::Contact || Hubspot::Company] a contact or company
      # @return [Array] Array of Hubspot::Deal records
      def find_by_association(object)
        definition = case object
                     when Hubspot::Company then Hubspot::Association::COMPANY_TO_DEAL
                     when Hubspot::Contact then Hubspot::Association::CONTACT_TO_DEAL
                     else raise(Hubspot::InvalidParams, 'Instance type not supported')
                     end
        Hubspot::Association.all(object.id, definition)
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
      query = { 'properties' => Hubspot::Utils.hash_to_properties(params.stringify_keys!, key_name: 'name') }
      Hubspot::Connection.put_json(UPDATE_DEAL_PATH, params: { deal_id: deal_id }, body: query)
      @properties.merge!(params)
      self
    end
    alias_method :update, :update!
  end
end
