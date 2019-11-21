class Hubspot::Association
  COMPANY_TO_CONTACT = 2
  DEAL_TO_CONTACT = 3
  CONTACT_TO_DEAL = 4
  DEAL_TO_COMPANY = 5
  COMPANY_TO_DEAL = 6
  DEFINITION_TARGET_TO_CLASS = {
    2 => Hubspot::Contact,
    3 => Hubspot::Contact,
    4 => Hubspot::Deal,
    5 => Hubspot::Company,
    6 => Hubspot::Deal
  }.freeze

  BATCH_CREATE_PATH = '/crm-associations/v1/associations/create-batch'
  BATCH_DELETE_PATH = '/crm-associations/v1/associations/delete-batch'
  ASSOCIATIONS_PATH = '/crm-associations/v1/associations/:resource_id/HUBSPOT_DEFINED/:definition_id'

  class << self
    def create(from_id, to_id, definition_id)
      batch_create([{ from_id: from_id, to_id: to_id, definition_id: definition_id }])
    end

    # Make multiple associations in a single API call
    # {https://developers.hubspot.com/docs/methods/crm-associations/batch-associate-objects}
    # usage:
    # Hubspot::Association.batch_create([{ from_id: 1, to_id: 2, definition_id: Hubspot::Association::COMPANY_TO_CONTACT }])
    def batch_create(associations)
      request = associations.map { |assocation| build_association_body(assocation) }
      Hubspot::Connection.put_json(BATCH_CREATE_PATH, params: { no_parse: true }, body: request).success?
    end

    def delete(from_id, to_id, definition_id)
      batch_delete([{from_id: from_id, to_id: to_id, definition_id: definition_id}])
    end

    # Remove multiple associations in a single API call
    # {https://developers.hubspot.com/docs/methods/crm-associations/batch-delete-associations}
    # usage:
    # Hubspot::Association.batch_delete([{ from_id: 1, to_id: 2, definition_id: Hubspot::Association::COMPANY_TO_CONTACT }])
    def batch_delete(associations)
      request = associations.map { |assocation| build_association_body(assocation) }
      Hubspot::Connection.put_json(BATCH_DELETE_PATH, params: { no_parse: true }, body: request).success?
    end

    # Retrieve all associated resources given a source (resource_id) and a kind (definition_id)
    # Example: if resource_id is a deal, using DEAL_TO_CONTACT will find every contact associated with the deal
    # {https://developers.hubspot.com/docs/methods/crm-associations/get-associations}
    # Warning: it will make N+M queries, where
    #   N is the number of PagedCollection requests necessary to get all ids,
    #   and M is the number of results, each resulting in a find
    # usage:
    # Hubspot::Association.all(42, Hubspot::Association::DEAL_TO_CONTACT)
    def all(resource_id, definition_id)
      opts = { resource_id: resource_id, definition_id: definition_id }
      klass = DEFINITION_TARGET_TO_CLASS[definition_id]
      raise(Hubspot::InvalidParams, 'Definition not supported') unless klass.present?

      collection = Hubspot::PagedCollection.new(opts) do |options, offset, limit|
        params = options.merge(offset: offset, limit: limit)
        response = Hubspot::Connection.get_json(ASSOCIATIONS_PATH, params)

        resources = response['results'].map { |result| klass.find(result) }
        [resources, response['offset'], response['has-more']]
      end
      collection.resources
    end

    private

    def build_association_body(assocation)
      {
        fromObjectId: assocation[:from_id],
        toObjectId: assocation[:to_id],
        category: 'HUBSPOT_DEFINED',
        definitionId: assocation[:definition_id]
      }
    end
  end
end
