module Hubspot
  class Company2 < Hubspot::Resource
    self.id_field = "companyId"
    self.property_name_field = "name"

    CREATE_PATH         = '/companies/v2/companies/'
    DELETE_PATH         = '/companies/v2/companies/:id'
    FIND_PATH           = '/companies/v2/companies/:id'
    SEARCH_DOMAIN_PATH  = '/companies/v2/domains/:domain/companies'
    UPDATE_PATH         = '/companies/v2/companies/:id'

    class << self
      def search_domain(domain, limit: 25, properties: [], offset: 0)
        request = {
          "limit" => limit,
          "requestOptions" => {
            "properties" => properties
          },
          "offset" => {
            "isPrimary" => true,
            "companyId" => offset
          }
        }

        response = Hubspot::Connection.post_json(SEARCH_DOMAIN_PATH, params: { domain: domain }, body: request)
        response["results"].map { |result| new(result["companyId"], result) }
      end
    end
  end
end