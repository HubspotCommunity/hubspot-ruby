require 'logger'
require 'hubspot/connection'

module Hubspot
  class Config
    CONFIG_KEYS = [
      :hapikey, :base_url, :portal_id, :logger, :access_token, :client_id,
      :client_secret, :redirect_uri, :read_timeout, :open_timeout
    ]
    DEFAULT_LOGGER = Logger.new(nil)
    DEFAULT_BASE_URL = "https://api.hubapi.com".freeze

    class << self
      attr_accessor *CONFIG_KEYS

      def configure(config)
        config.stringify_keys!
        @hapikey = config["hapikey"]
        @base_url = config["base_url"] || DEFAULT_BASE_URL
        @portal_id = config["portal_id"]
        @logger = config["logger"] || DEFAULT_LOGGER
        @access_token = config["access_token"]
        @client_id = config["client_id"] if config["client_id"].present?
        @client_secret = config["client_secret"] if config["client_secret"].present?
        @redirect_uri = config["redirect_uri"] if config["redirect_uri"].present?
        @read_timeout = config['read_timeout'] || config['timeout']
        @open_timeout = config['open_timeout'] || config['timeout']

        unless authentication_uncertain?
          raise Hubspot::ConfigurationError.new("You must provide either an access_token or an hapikey")
        end

        if access_token.present?
          Hubspot::Connection.headers("Authorization" => "Bearer #{access_token}")
        end
        self
      end

      def reset!
        @hapikey = nil
        @base_url = DEFAULT_BASE_URL
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

      private

      def authentication_uncertain?
        access_token.present? ^ hapikey.present?
      end
    end

    reset!
  end
end
