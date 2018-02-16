module Hubspot
  #
  # HubSpot Workflow API
  #
  # {https://developers.hubspot.com/docs/methods/workflows/workflows_overview}
  #
  # TODO: work on all endpoints
  class Workflow
    GET_WORKFLOWS_PATH           = '/automation/v3/workflows'
    ENROLL_A_CONTACT_PATH        = '/automation/v2/workflows/:workflowId/enrollments/contacts/:email'

    class << self
      # {https://developers.hubspot.com/docs/methods/workflows/v3/get_workflows}
      def all(opts={})
        response = Hubspot::Connection.get_json(GET_WORKFLOWS_PATH, opts)
        response["workflows"].map! { |workflow| new(workflow) }
      end
    end

    attr_reader :id, :name

    def initialize(response_hash)
      @name = response_hash['name']
      @id = response_hash['id']
    end

    # {https://developers.hubspot.com/docs/methods/workflows/add_contact}
    def enroll_contact(email:)
      json = {params:
        {email: email, workflowId: @id},
        body: {}
      }
      Hubspot::Connection.post_json(ENROLL_A_CONTACT_PATH, json)
    end

  end
end
