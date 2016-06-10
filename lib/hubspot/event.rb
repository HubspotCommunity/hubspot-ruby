module Hubspot
  class Event

    TRACK_EVENT_URL = '/v1/event/'

    class << self
      def track(event_name, opts = {})
        params = opts.merge(_n: event_name)
        Hubspot::Connection.track(TRACK_EVENT_URL, params.stringify_keys!)
      end
    end

  end
end
