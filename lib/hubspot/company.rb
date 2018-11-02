module Hubspot
  #
  # HubSpot Companies API
  #
  # {http://developers.hubspot.com/docs/methods/companies/companies-overview}
  #
  class Company
    CREATE_COMPANY_PATH              = "/companies/v2/companies/"
    RECENTLY_CREATED_COMPANIES_PATH  = "/companies/v2/companies/recent/created"
    RECENTLY_MODIFIED_COMPANIES_PATH = "/companies/v2/companies/recent/modified"
    GET_COMPANY_BY_ID_PATH           = "/companies/v2/companies/:company_id"
    GET_COMPANY_BY_DOMAIN_PATH       = "/companies/v2/domains/:domain/companies"
    UPDATE_COMPANY_PATH              = "/companies/v2/companies/:company_id"
    GET_COMPANY_CONTACT_VIDS_PATH    = "/companies/v2/companies/:company_id/vids"
    ADD_CONTACT_TO_COMPANY_PATH      = "/companies/v2/companies/:company_id/contacts/:vid"
    DESTROY_COMPANY_PATH             = "/companies/v2/companies/:company_id"
    GET_COMPANY_CONTACTS_PATH        = "/companies/v2/companies/:company_id/contacts"
    BATCH_UPDATE_PATH                = "/companies/v1/batch-async/update"

    class << self
      # Find all companies by created date (descending)
      # @param opts [Hash] Possible options are:
      #    recently_updated [boolean] (for querying all accounts by modified time)
      #    count [Integer] for pagination
      #    offset [Integer] for pagination
      # {http://developers.hubspot.com/docs/methods/companies/get_companies_created}
      # {http://developers.hubspot.com/docs/methods/companies/get_companies_modified}
      # @return [Array] Array of Hubspot::Company records
      def all(opts={})
        recently_updated = opts.delete(:recently_updated) { false }
        # limit = opts.delete(:limit) { 20 }
        # skip = opts.delete(:skip) { 0 }
        path = if recently_updated
          RECENTLY_MODIFIED_COMPANIES_PATH
        else
          RECENTLY_CREATED_COMPANIES_PATH
        end

        response = Hubspot::Connection.get_json(path, opts)
        response['results'].map { |c| new(c) }
      end

      # Find all companies by created date (descending)
      #    recently_updated [boolean] (for querying all accounts by modified time)
      #    count [Integer] for pagination
      #    offset [Integer] for pagination
      # {http://developers.hubspot.com/docs/methods/companies/get_companies_created}
      # {http://developers.hubspot.com/docs/methods/companies/get_companies_modified}
      # @return [Object], you can get:
      # response.results for [Array]
      # response.hasMore for [Boolean]
      # response.offset for [Integer]
      def all_with_offset(opts = {})
        recently_updated = opts.delete(:recently_updated) { false }

        path = if recently_updated
          RECENTLY_MODIFIED_COMPANIES_PATH
        else
          RECENTLY_CREATED_COMPANIES_PATH
        end

        response = Hubspot::Connection.get_json(path, opts)
        response_with_offset = {}
        response_with_offset['results'] = response['results'].map { |c| new(c) }
        response_with_offset['hasMore'] = response['hasMore']
        response_with_offset['offset'] = response['offset']
        response_with_offset
      end

      # Finds a list of companies by domain
      # {https://developers.hubspot.com/docs/methods/companies/search_companies_by_domain}
      # @param domain [String] company domain to search by
      # @param options [Hash] Possible options are:
      #    limit [Integer] for pagination
      #    properties [Array] list of company properties to recieve
      #    offset_company_id [Integer] for pagination (should be company ID)
      # @return [Array] Array of Hubspot::Company records
      def find_by_domain(domain, options = {})
        raise Hubspot::InvalidParams, 'expecting String parameter' unless domain.try(:is_a?, String)

        limit = options.fetch(:limit, 100)
        properties = options.fetch(:properties) { Hubspot::CompanyProperties.all.map { |property| property["name"] } }
        offset_company_id = options.fetch(:offset_company_id, nil)

        post_data = {
          "limit" => limit,
          "requestOptions" => {
            "properties" => properties
          }
        }
        post_data["offset"] = {
          "isPrimary" => true,
          "companyId" => offset_company_id
        } if offset_company_id

        companies = []
        begin
          response = Hubspot::Connection.post_json(GET_COMPANY_BY_DOMAIN_PATH, params: { domain: domain }, body: post_data )
          companies = response["results"].try(:map) { |company| new(company) }
        rescue => e
          raise e unless e.message =~ /not found/ # 404 / hanle the error and kindly return an empty array
        end
        companies
      end

      # Finds a company by domain
      # {http://developers.hubspot.com/docs/methods/companies/get_company}
      # @param id [Integer] company id to search by
      # @return [Hubspot::Company] Company record
      def find_by_id(id)
        path = GET_COMPANY_BY_ID_PATH
        params = { company_id: id }
        raise Hubspot::InvalidParams, 'expecting Integer parameter' unless id.try(:is_a?, Integer)
        response = Hubspot::Connection.get_json(path, params)
        new(response)
      end

      # Creates a company with a name
      # {http://developers.hubspot.com/docs/methods/companies/create_company}
      # @param name [String]
      # @return [Hubspot::Company] Company record
      def create!(name, params={})
        params_with_name = params.stringify_keys.merge("name" => name)
        post_data = {properties: Hubspot::Utils.hash_to_properties(params_with_name, key_name: "name")}
        response = Hubspot::Connection.post_json(CREATE_COMPANY_PATH, params: {}, body: post_data )
        new(response)
      end

      # Updates the properties of companies
      # NOTE: Up to 100 companies can be updated in a single request. There is no limit to the number of properties that can be updated per company.
      # {https://developers.hubspot.com/docs/methods/companies/batch-update-companies}
      # Returns a 202 Accepted response on success.
      def batch_update!(companies)
        query = companies.map do |company|
          company_hash = company.with_indifferent_access
          if company_hash[:vid]
            # For consistency - Since vid has been used everywhere.
            company_param = {
              objectId: company_hash[:vid],
              properties: Hubspot::Utils.hash_to_properties(company_hash.except(:vid).stringify_keys!, key_name: 'name'),
            }
          elsif company_hash[:objectId]
            company_param = {
              objectId: company_hash[:objectId],
              properties: Hubspot::Utils.hash_to_properties(company_hash.except(:objectId).stringify_keys!, key_name: 'name'),
            }
          else
            raise Hubspot::InvalidParams, 'expecting vid or objectId for company'
          end
          company_param
        end
        Hubspot::Connection.post_json(BATCH_UPDATE_PATH, params: {}, body: query)
      end
    
      # Adds contact to a company
      # {http://developers.hubspot.com/docs/methods/companies/add_contact_to_company}
      # @param company_vid [Integer] The ID of a company to add a contact to
      # @param contact_vid [Integer] contact id to add
      # @return parsed response
      def add_contact!(company_vid, contact_vid)
        Hubspot::Connection.put_json(ADD_CONTACT_TO_COMPANY_PATH,
                                     params: {
                                       company_id: company_vid,
                                       vid: contact_vid,
                                     },
                                     body: nil)
      end
    end

    attr_reader :properties
    attr_reader :vid, :name

    def initialize(response_hash)
      @properties = Hubspot::Utils.properties_to_hash(response_hash["properties"])
      @vid = response_hash["companyId"]
      @name = @properties.try(:[], "name")
    end

    def [](property)
      @properties[property]
    end

    # Updates the properties of a company
    # {http://developers.hubspot.com/docs/methods/companies/update_company}
    # @param params [Hash] hash of properties to update
    # @return [Hubspot::Company] self
    def update!(params)
      query = {"properties" => Hubspot::Utils.hash_to_properties(params.stringify_keys!, key_name: "name")}
      Hubspot::Connection.put_json(UPDATE_COMPANY_PATH, params: { company_id: vid }, body: query)
      @properties.merge!(params)
      self
    end

    # Gets ALL contact vids of a company
    # May make many calls if the company has a mega-ton of contacts
    # {http://developers.hubspot.com/docs/methods/companies/get_company_contacts_by_id}
    # @return [Array] contact vids
    def get_contact_vids
      vid_offset = nil
      vids = []
      loop do
        data = Hubspot::Connection.get_json(GET_COMPANY_CONTACT_VIDS_PATH,
                                            company_id: vid,
                                            vidOffset: vid_offset)
        vids += data['vids']
        return vids unless data['hasMore']
        vid_offset = data['vidOffset']
      end
      vids # this statement will never be executed.
    end

    # Adds contact to a company
    # {http://developers.hubspot.com/docs/methods/companies/add_contact_to_company}
    # @param id [Integer] contact id to add
    # @return [Hubspot::Company] self
    def add_contact(contact_or_vid)
      contact_vid = if contact_or_vid.is_a?(Hubspot::Contact)
                      contact_or_vid.vid
                    else
                      contact_or_vid
                    end
      self.class.add_contact!(vid, contact_vid)
      self
    end

    # Archives the company in hubspot
    # {http://developers.hubspot.com/docs/methods/companies/delete_company}
    # @return [TrueClass] true
    def destroy!
      Hubspot::Connection.delete_json(DESTROY_COMPANY_PATH, { company_id: vid })
      @destroyed = true
    end

    def destroyed?
      !!@destroyed
    end

    # Finds company contacts
    # {http://developers.hubspot.com/docs/methods/companies/get_company_contacts}
    # @return [Array] Array of Hubspot::Contact records
    def contacts
      response = Hubspot::Connection.get_json(GET_COMPANY_CONTACTS_PATH, company_id: vid)
      response['contacts'].each_with_object([]) do |contact, memo|
        memo << Hubspot::Contact.find_by_id(contact['vid'])
      end
    end
  end
end
