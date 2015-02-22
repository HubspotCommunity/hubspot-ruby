module Hubspot
  class Connection
    include HTTParty

    class << self
      def get_json(path, opts)
        url = Hubspot::Utils.generate_url(path, opts)
        response = get(url, format: :json)
        raise(Hubspot::RequestError.new(response)) unless response.success?
        response.parsed_response
      end

      def post_json(path, opts)
        no_parse = opts[:params].delete(:no_parse) { false }

        url = Hubspot::Utils.generate_url(path, opts[:params])
        response = post(url, body: opts[:body].to_json, headers: { 'Content-Type' => 'application/json' }, format: :json)
        raise(Hubspot::RequestError.new(response)) unless response.success?
        
        no_parse ? response : response.parsed_response
      end

      def delete_json(path, opts)
        url = Hubspot::Utils.generate_url(path, opts)
        response = delete(url, format: :json)
        raise(Hubspot::RequestError.new(response)) unless response.success?
        response
      end
    end
  end
end