require 'hubspot/utils'

module Hubspot
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
        response = Hubspot::Connection.get_json(PIPELINE_PATH, { pipeline_id: pipeline_id })
        new(response)
      end

      def all
        response = Hubspot::Connection.get_json(PIPELINES_PATH, {})
        response.map { |p| new(p) }
      end
    end

    def [](stage)
      @stages[stage]
    end
  end
end
