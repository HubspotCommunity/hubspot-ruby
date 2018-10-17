require 'httparty'
module Hubspot
  class OAuth < Connection
    include HTTParty
    DEFAULT_OAUTH_HEADERS = {"Content-Type" => "application/x-www-form-urlencoded;charset=utf-8"}
    class << self
      def refresh(params)
        params.stringify_keys!
        no_parse = params.delete("no_parse") { false }
        body = {
          client_id: params["client_id"] || Hubspot::Config.client_id,
          grant_type: "refresh_token",
          client_secret: params["client_secret"] || Hubspot::Config.client_secret,
          redirect_uri: params["redirect_uri"] || Hubspot::Config.redirect_uri,
          refresh_token: params["refresh_token"]
        }
        response = post(oauth_url, body: body, headers: DEFAULT_OAUTH_HEADERS)
        log_request_and_response oauth_url, response, body
        raise(Hubspot::RequestError.new(response)) unless response.success?

        no_parse ? response : response.parsed_response
      end

      def create(params)
        params.stringify_keys!
        no_parse = params.delete("no_parse") { false }
        body = {
          client_id: params["client_id"] || Hubspot::Config.client_id,
          grant_type: "authorization_code",
          client_secret: params["client_secret"] || Hubspot::Config.client_secret,
          redirect_uri: params["redirect_uri"] || Hubspot::Config.redirect_uri,
          code: params["code"]
        }
        response = post(oauth_url, body: body, headers: DEFAULT_OAUTH_HEADERS)
        log_request_and_response oauth_url, response, body
        raise(Hubspot::RequestError.new(response)) unless response.success?

        no_parse ? response : response.parsed_response
      end

      def oauth_url
        oauth_url = Hubspot::Config.base_url + "/oauth/v1/token"
      end
    end
  end
end
