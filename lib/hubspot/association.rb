class Hubspot::Association
  COMPANY_TO_CONTACT = 2
  DEAL_TO_CONTACT = 3
  DEAL_TO_COMPANY = 5

  BATCH_CREATE_PATH = '/crm-associations/v1/associations/create-batch'
  BATCH_DELETE_PATH = '/crm-associations/v1/associations/delete-batch'

  class << self
    def create(from_id, to_id, definition_id)
      batch_create([{from_id: from_id, to_id: to_id, definition_id: definition_id}])
    end

    def batch_create(associations)
      request = associations.map { |assocation| build_association_body(assocation) }
      Hubspot::Connection.put_json(BATCH_CREATE_PATH, params: { no_parse: true }, body: request).success?
    end

    def delete(from_id, to_id, definition_id)
      batch_create([{from_id: from_id, to_id: to_id, definition_id: definition_id}])
    end

    def batch_delete(associations)
      request = associations.map { |assocation| build_association_body(assocation) }
      Hubspot::Connection.put_json(BATCH_CREATE_PATH, params: { no_parse: true }, body: request).success?
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
