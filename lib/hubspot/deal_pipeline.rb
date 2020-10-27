require 'hubspot/utils'

module HubspotLegacy
  #
  # HubSpot Deals API
  #
  # {http://developers.hubspot.com/docs/methods/deal-pipelines/overview}
  #
  class DealPipeline
    PIPELINES_PATH = "/deals/v1/pipelines"
    PIPELINE_PATH = "/deals/v1/pipelines/:pipeline_id"

    attr_reader :active
    attr_reader :display_order
    attr_reader :label
    attr_reader :pipeline_id
    attr_reader :stages

    def initialize(response_hash)
      @active = response_hash["active"]
      @display_order = response_hash["displayOrder"]
      @label = response_hash["label"]
      @pipeline_id = response_hash["pipelineId"]
      @stages = response_hash["stages"]
    end

    class << self
      def find(pipeline_id)
        response = HubspotLegacy::Connection.get_json(PIPELINE_PATH, { pipeline_id: pipeline_id })
        new(response)
      end

      def all
        response = HubspotLegacy::Connection.get_json(PIPELINES_PATH, {})
        response.map { |p| new(p) }
      end

      # Creates a DealPipeline
      # {https://developers.hubspot.com/docs/methods/deal-pipelines/create-deal-pipeline}
      # @return [HubspotLegacy::PipeLine] Company record
      def create!(post_data={})
        response = HubspotLegacy::Connection.post_json(PIPELINES_PATH, params: {}, body: post_data)
        new(response)
      end
    end

    # Destroys deal_pipeline
    # {http://developers.hubspot.com/docs/methods/companies/delete_company}
    # @return [TrueClass] true
    def destroy!
      HubspotLegacy::Connection.delete_json(PIPELINE_PATH, pipeline_id: @pipeline_id)
    end

    def [](stage)
      @stages[stage]
    end
  end
end
