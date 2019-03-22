module Hubspot
  class CrmAssociations

    ALL_ASSOCIATIONS_PATH = '/crm-associations/v1/associations/:object_id/HUBSPOT_DEFINED/:definition_id'
    CREATE_ASSOCIATIONS_PATH = '/crm-associations/v1/associations'
    BATCH_CREATE_ASSOCIATIONS_PATH = '/crm-associations/v1/associations/create-batch'

    class << self
      # params should contain object_id and definition_id
      # https://developers.hubspot.com/docs/methods/crm-associations/get-associations
      def get(opts = {})
        Hubspot::PagedCollection.new(opts) do |options, offset, limit|
          response = Hubspot::Connection.get_json(
              ALL_ASSOCIATIONS_PATH,
              options.merge(offset: offset, limit: limit)
          )

          [response["results"], response["offset"], response["hasMore"]]
        end
      end

      # params should contain fromObjectId, toObjectId, definitionId
      # https://developers.hubspot.com/docs/methods/crm-associations/associate-objects
      def create(params={})
        Hubspot::Connection.put_json(
            CREATE_ASSOCIATIONS_PATH,
            params: params.merge(category: 'HUBSPOT_DEFINED')
        )
      end

      # params should contain [{fromObjectId, toObjectId, definitionId, category}]
      # https://developers.hubspot.com/docs/methods/crm-associations/batch-associate-objects
      def batch_create(params=[])
        Hubspot::Connection.put_json(
            BATCH_CREATE_ASSOCIATIONS_PATH,
            params:{},
            body: params
        )
        true
      end
    end
  end
end
