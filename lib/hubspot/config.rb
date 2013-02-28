module Hubspot
  class Config
    class << self
      attr_reader :hapikey
      attr_reader :base_url
      attr_reader :portal_id

      def configure(config)
        config.stringify_keys!
        @hapikey = config["hapikey"]
        @base_url = config["base_url"] || "https://api.hubapi.com"
        @portal_id = config["portal_id"]
        self
      end

      def reset!
        @hapikey = nil
        @base_url = "https://api.hubapi.com"
        @portal_id = nil
      end

      def ensure!(*params)
        params.each do |p|
          raise Hubspot::ConfigurationError.new("'#{p}' not configured") unless instance_variable_get "@#{p}"
        end
      end
    end

    reset!
  end
end