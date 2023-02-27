require 'httparty'

module Hubspot
  class OAuth < Connection
    include HTTParty

    DEFAULT_OAUTH_HEADERS = {"Content-Type" => "application/x-www-form-urlencoded;charset=utf-8"}

    class << self
      def refresh(config, token, params={}, options={})
        oauth_post(config, { grant_type: "refresh_token", refresh_token: token }.merge(params),
          options)
      end

      def create(config, code, params={}, options={})
        oauth_post(config, { grant_type: "authorization_code", code: code }.merge(params),
          options)
      end

      def authorize_url(config, scopes, params={})
        client_id = params[:client_id] || config.client_id
        redirect_uri = params[:redirect_uri] || config.redirect_uri
        scopes = Array.wrap(scopes)

        "https://app.hubspot.com/oauth/authorize?client_id=#{client_id}&scope=#{scopes.join("%20")}&redirect_uri=#{redirect_uri}"
      end

      def token_url(config)
        config.base_url + "/oauth/v1/token"
      end

      def oauth_post(config, params, options={})
        no_parse = options[:no_parse] || false

        url = token_url(config)
        body = {
          client_id: config.client_id,
          client_secret: config.client_secret,
          redirect_uri: config.redirect_uri,
        }.merge(params)

        response = post(url, body: body, headers: DEFAULT_OAUTH_HEADERS)

        raise(Hubspot::RequestError.new(response)) unless response.success?

        no_parse ? response : response.parsed_response
      end
    end
  end
end
