require 'httparty'

module Hubspot
  class OAuth < Connection
    include HTTParty

    DEFAULT_OAUTH_HEADERS = {"Content-Type" => "application/x-www-form-urlencoded;charset=utf-8"}

    class << self
      def refresh(token, params={}, options={})
        oauth_post(token_url, { grant_type: "refresh_token", refresh_token: token }.merge(params),
          options)
      end

      def create(code, params={}, options={})
        oauth_post(token_url, { grant_type: "authorization_code", code: code }.merge(params),
          options)
      end

      def authorize_url(scopes, params={})
        client_id = params[:client_id] || Hubspot::Config.client_id
        redirect_uri = params[:redirect_uri] || Hubspot::Config.redirect_uri
        scopes = Array.wrap(scopes)

        "https://app.hubspot.com/oauth/authorize?client_id=#{client_id}&scope=#{scopes.join("%20")}&redirect_uri=#{redirect_uri}"
      end

      def token_url
        token_url = Hubspot::Config.base_url + "/oauth/v1/token"
      end

      def oauth_post(url, params, options={})
        no_parse = options[:no_parse] || false

        body = {
          client_id: Hubspot::Config.client_id,
          client_secret: Hubspot::Config.client_secret,
          redirect_uri: Hubspot::Config.redirect_uri,
        }.merge(params)

        response = post(url, body: body, headers: DEFAULT_OAUTH_HEADERS)
        log_request_and_response url, response, body

        raise(Hubspot::RequestError.new(response)) unless response.success?

        no_parse ? response : response.parsed_response
      end
    end
  end
end
