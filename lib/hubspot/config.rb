require 'logger'
require 'hubspot/connection'

module Hubspot
  class Config

    CONFIG_KEYS = [
      :hapikey, :base_url, :portal_id, :logger, :access_token, :client_id,
      :client_secret, :redirect_uri
    ]
    DEFAULT_LOGGER = Logger.new('/dev/null')

    class << self
      attr_accessor *CONFIG_KEYS

      def configure(config)
        config.stringify_keys!
        @hapikey = config["hapikey"]
        @base_url = config["base_url"] || "https://api.hubapi.com"
        @portal_id = config["portal_id"]
        @logger = config["logger"] || DEFAULT_LOGGER
        @access_token = config["access_token"]
        @client_id = config["client_id"] if config["client_id"].present?
        @client_secret = config["client_secret"] if config["client_secret"].present?
        @redirect_uri = config["redirect_uri"] if config["redirect_uri"].present?

        unless access_token.present? ^ hapikey.present?
          Hubspot::ConfigurationError.new("You must provide either an access_token or an hapikey")
        end
        if access_token.present?
          Hubspot::Connection.headers("Authorization" => "Bearer #{access_token}")
        end
        self
      end

      def reset!
        @hapikey = nil
        @base_url = "https://api.hubapi.com"
        @portal_id = nil
        @logger = DEFAULT_LOGGER
        @access_token = nil
        Hubspot::Connection.headers({})
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
