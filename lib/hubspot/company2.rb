class Hubspot::Company2 < Hubspot::Resource
  self.id_field = "companyId"
  self.property_name_field = "name"

  ADD_CONTACT_PATH        = '/companies/v2/companies/:id/contacts/:contact_id'
  ALL_PATH                = '/companies/v2/companies/paged'
  CREATE_PATH             = '/companies/v2/companies/'
  DELETE_PATH             = '/companies/v2/companies/:id'
  FIND_PATH               = '/companies/v2/companies/:id'
  RECENTLY_CREATED_PATH   = '/companies/v2/companies/recent/created'
  RECENTLY_MODIFIED_PATH  = '/companies/v2/companies/recent/modified'
  SEARCH_DOMAIN_PATH      = '/companies/v2/domains/:domain/companies'
  UPDATE_PATH             = '/companies/v2/companies/:id'

  class << self
    def all(opts = {})
      Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        response = Hubspot::Connection.get_json(
          ALL_PATH,
          options.merge(offset: offset, limit: limit)
        )

        companies = response["companies"].map { |result| new(result) }

        [companies, response["offset"], response["has-more"]]
      end
    end

    def search_domain(domain, opts = {})
      Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        request = {
          "limit" => limit,
          "requestOptions" => options,
          "offset" => {
            "isPrimary" => true,
            "companyId" => offset
          }
        }

        response = Hubspot::Connection.post_json(
          SEARCH_DOMAIN_PATH,
          params: { domain: domain },
          body: request
        )

        companies = response["results"].map { |result| new(result) }

        [companies, response["offset"]["companyId"], response["hasMore"]]
      end
    end

    def recently_created(opts = {})
      Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        response = Hubspot::Connection.get_json(
          RECENTLY_CREATED_PATH,
          {offset: offset, count: limit}
        )

        companies = response["results"].map { |result| new(result) }

        [companies, response["offset"], response["hasMore"]]
      end
    end

    def recently_modified(opts = {})
      Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        response = Hubspot::Connection.get_json(
          RECENTLY_MODIFIED_PATH,
          {offset: offset, count: limit}
        )

        companies = response["results"].map { |result| new(result) }

        [companies, response["offset"], response["hasMore"]]
      end
    end

    def add_contact(id, contact_id)
      Hubspot::Connection.put_json(
        ADD_CONTACT_PATH,
        params: { id: id, contact_id: contact_id}
      )
      true
    end
  end
end
