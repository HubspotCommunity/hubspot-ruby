module Hubspot
  class Config
    class << self
      attr_reader :hapikey
      attr_reader :base_url

      def configure(config)
        config.stringify_keys!
        @hapikey = config["hapikey"]
        @base_url = config["base_url"] || "https://api.hubapi.com"
        self
      end

      def reset!
        @hapikey = nil
        @base_url = "https://api.hubapi.com"
      end
    end

    reset!
  end
end