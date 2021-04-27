class Hubspot::Company < Hubspot::Resource
  self.id_field = "companyId"
  self.property_name_field = "name"

  ADD_CONTACT_PATH        = '/companies/v2/companies/:id/contacts/:contact_id'
  ALL_PATH                = '/companies/v2/companies/paged'
  BATCH_UPDATE_PATH       = '/companies/v1/batch-async/update'
  CONTACTS_PATH           = '/companies/v2/companies/:id/contacts'
  CONTACT_IDS_PATH        = '/companies/v2/companies/:id/vids'
  CREATE_PATH             = '/companies/v2/companies/'
  DELETE_PATH             = '/companies/v2/companies/:id'
  FIND_PATH               = '/companies/v2/companies/:id'
  RECENTLY_CREATED_PATH   = '/companies/v2/companies/recent/created'
  RECENTLY_MODIFIED_PATH  = '/companies/v2/companies/recent/modified'
  REMOVE_CONTACT_PATH     = '/companies/v2/companies/:id/contacts/:contact_id'
  SEARCH_DOMAIN_PATH      = '/companies/v2/domains/:domain/companies'
  UPDATE_PATH             = '/companies/v2/companies/:id'
  ASSOCIATE_COMPANY_TO_CONTACT_PATH = '/crm-associations/v1/associations'

  class << self
    def all(opts = {})
      Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        response = Hubspot::Connection.get_json(
          ALL_PATH,
          options.merge(offset: offset, limit: limit)
        )

        companies = response["companies"].map { |result| from_result(result) }

        [companies, response["offset"], response["has-more"]]
      end
    end

    def search_domain(domain, opts = {})
      Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        request = {
          "limit" => 2,
          "requestOptions" => { 'properties': ['domain', 'createdate', 'name', 'hs_lastmodifieddate'] },
          "offset" => {
            "isPrimary" => true,
            "companyId" => 0
          }
        }

        response = Hubspot::Connection.post_json(
          SEARCH_DOMAIN_PATH,
          params: { domain: domain },
          body: request
        )

        companies = response["results"].map { |result| from_result(result) }

        [companies, response["offset"]["companyId"], response["hasMore"]]
      end
    end

    def update_company(company_id, properties = {})
      if company_id.present?
        path = UPDATE_PATH
        params = { id: company_id}
      end
      request = JSON.parse(properties)
      if company_id.present?
        response = Hubspot::Connection.put_json(path, params: params, body: request)
      end
      from_result(response)
    end

    def create_or_update(company_id, properties = {})
      if company_id.present?
        path = UPDATE_PATH
        params = { id: company_id}
      else
        path = CREATE_PATH
        params = {}
      end
      request = JSON.parse(properties)
      if company_id.present?
        response = Hubspot::Connection.put_json(path, params: params, body: request)
      else
        response = Hubspot::Connection.post_json(path, params: params, body: request)
      end
      from_result(response)
    end

    def associate_contact_to_company(properties = {})
      response = Hubspot::Connection.put_json(
        ASSOCIATE_COMPANY_TO_CONTACT_PATH,
        params: {}, body: properties
      )
    end

    def recently_created(opts = {})
      Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        response = Hubspot::Connection.get_json(
          RECENTLY_CREATED_PATH,
          {offset: offset, count: limit}
        )

        companies = response["results"].map { |result| from_result(result) }

        [companies, response["offset"], response["hasMore"]]
      end
    end

    def recently_modified(opts = {})
      Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        response = Hubspot::Connection.get_json(
          RECENTLY_MODIFIED_PATH,
          {offset: offset, count: limit}
        )

        companies = response["results"].map { |result| from_result(result) }

        [companies, response["offset"], response["hasMore"]]
      end
    end

    def add_contact(id, contact_id)
      Hubspot::Connection.put_json(
        ADD_CONTACT_PATH,
        params: { id: id, contact_id: contact_id }
      )
      true
    end

    def remove_contact(id, contact_id)
      Hubspot::Connection.delete_json(
        REMOVE_CONTACT_PATH,
        { id: id, contact_id: contact_id }
      )

      true
    end

    def batch_update(request)
      # request = companies.map do |company|
      #   # Use the specified options or update with the changes
      #   changes = opts.empty? ? company.changes : opts

      #   unless changes.empty?
      #     {
      #       "objectId" => company.id,
      #       "properties" => changes.map { |k, v| { "name" => k, "value" => v } }
      #     }
      #   end
      # end

      # Remove any objects without changes and return if there is nothing to update
      request.compact
      return true if request.empty?

      Hubspot::Connection.post_json(
        BATCH_UPDATE_PATH,
        params: {},
        body: request
      )

      true
    end

    def company_by_id(company_id)
      if company_id.present?
        path = FIND_PATH
        params = { id: company_id }
        response = Hubspot::Connection.get_json(path, params: params)
      end
    end
  end

  def contacts(opts = {})
    Hubspot::PagedCollection.new(opts) do |options, offset, limit|
      response = Hubspot::Connection.get_json(
        CONTACTS_PATH,
        {"id" => @id, "vidOffset" => offset, "count" => limit}
      )

      contacts = response["contacts"].map do |result|
        result["properties"] = Hubspot::Utils.properties_array_to_hash(result["properties"])
        Hubspot::Contact.from_result(result)
      end

      [contacts, response["vidOffset"], response["hasMore"]]
    end
  end

  def contact_ids(opts = {})
    Hubspot::PagedCollection.new(opts) do |options, offset, limit|
      response = Hubspot::Connection.get_json(
        CONTACT_IDS_PATH,
        {"id" => @id, "vidOffset" => offset, "count" => limit}
      )

      [response["vids"], response["vidOffset"], response["hasMore"]]
    end
  end

  def add_contact(contact)
    self.class.add_contact(@id, contact.to_i)
  end

  def remove_contact(contact)
    self.class.remove_contact(@id, contact.to_i)
  end
end
