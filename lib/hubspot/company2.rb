module Hubspot
  class Company2 < Hubspot::Resource
    self.id_field = "companyId"
    self.property_name_field = "name"

    ALL_PATH            = '/companies/v2/companies/paged'
    CREATE_PATH         = '/companies/v2/companies/'
    DELETE_PATH         = '/companies/v2/companies/:id'
    FIND_PATH           = '/companies/v2/companies/:id'
    SEARCH_DOMAIN_PATH  = '/companies/v2/domains/:domain/companies'
    UPDATE_PATH         = '/companies/v2/companies/:id'

    class << self
      def all(opts = {})
        PagedCollection.new(opts) do |options, offset, limit|
          response = Hubspot::Connection.get_json(
            ALL_PATH,
            options.merge(offset: offset, limit: limit)
          )

          companies = response["companies"].map { |result| new(result) }

          [companies, response["offset"], response["has-more"]]
        end
      end

      def search_domain(domain, opts = {})
        PagedCollection.new(opts) do |options, offset, limit|
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
    end
  end
end