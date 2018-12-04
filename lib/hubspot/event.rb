require 'hubspot/utils'

module Hubspot
  #
  # HubSpot Events HTTP API
  #
  # {https://developers.hubspot.com/docs/methods/enterprise_events/http_api}
  #
  class Event
    GET_EVENTS_PATH = '/reports/v2/events'
    POST_EVENT_PATH = '/v1/event'

    class << self
      def trigger(event_id, email, options = {})
        default_params = { _n: event_id, _a: Hubspot::Config.portal_id, email: email }
        options[:params] = default_params.merge(options[:params] || {})

        Hubspot::EventConnection.trigger(POST_EVENT_PATH, options).success?
      end

      def all(opts = {})
        response = Hubspot::Connection.get_json(GET_EVENTS_PATH, opts)
        response.map { |c| new(c) }
      end
    end

    def initialize(response_hash)
      @properties = response_hash
      @name = response_hash['name']
      @id = response_hash['id']
      @status = response_hash['status']
    end

    attr_reader :properties,
      :name,
      :id,
      :status
  end
end
