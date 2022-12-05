require 'logger'
require 'hubspot/connection'

module Hubspot
  class Config
    CONFIG_KEYS = [
      :hapikey, :base_url, :portal_id, :logger, :access_token, :client_id,
      :client_secret, :redirect_uri, :read_timeout, :open_timeout, :default_headers
    ]
    DEFAULT_LOGGER = Logger.new(nil)
    DEFAULT_BASE_URL = "https://api.hubapi.com".freeze

    class << self
      attr_reader :default_config

      CONFIG_KEYS.each do |key|
        namespaced_key = "hubspot-ruby-#{key}"

        unless respond_to?(key)
          define_method key do
            Thread.current[namespaced_key] || @default_config.try(:[], key.to_s)
          end
        end

        unless respond_to?("#{key}=")
          define_method "#{key}=" do |value|
            Thread.current[namespaced_key] = value
          end
        end
      end

      def access_token=(value)
        self.default_headers = default_headers.merge("Authorization" => "Bearer #{value}") if value
        Thread.current["hubspot-ruby-access_token"] = value
      end

      # @default_config stores the 'original' configuration so we don't have
      # to reconfigure in every thread, effectively allow inherited configs from a parent thread.
      #
      # When changing configuration via threads, @default_config will not
      # change without calling reset! first. This allows us to use the setter methods or .configure
      # within threads w/o changing the default state.
      def configure(config)
        config.stringify_keys!
        @default_config = config if @default_config.nil? # Prevent overwriting default_config w/o calling reset!

        config.each do |key, value|
          send("#{key}=", value)
        end

        unless authentication_uncertain?
          raise Hubspot::ConfigurationError.new("You must provide either an access_token or an hapikey")
        end

        self
      end

      def reset!
        @default_config = nil

        self.hapikey = nil
        self.base_url = DEFAULT_BASE_URL
        self.portal_id = nil
        self.logger = DEFAULT_LOGGER
        self.access_token = nil
        self.default_headers = {}
      end

      def ensure!(*params)
        params.each do |p|
          raise Hubspot::ConfigurationError.new("'#{p}' not configured") unless send(p)
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
