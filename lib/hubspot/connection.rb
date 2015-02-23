module Hubspot
  class Connection
    include HTTParty

    class << self
      def get_json(path, opts)
        url = generate_url(path, opts)
        response = get(url, format: :json)
        raise(Hubspot::RequestError.new(response)) unless response.success?
        response.parsed_response
      end

      def post_json(path, opts)
        no_parse = opts[:params].delete(:no_parse) { false }

        url = generate_url(path, opts[:params])
        response = post(url, body: opts[:body].to_json, headers: { 'Content-Type' => 'application/json' }, format: :json)
        raise(Hubspot::RequestError.new(response)) unless response.success?
        
        no_parse ? response : response.parsed_response
      end

      def delete_json(path, opts)
        url = generate_url(path, opts)
        response = delete(url, format: :json)
        raise(Hubspot::RequestError.new(response)) unless response.success?
        response
      end

      protected
    
      #TODO: refactor the following methods
      #      the base url pb can be solved using HTTParty base_uri option

      # Generate the API URL for the request
      #
      # @param path [String] The path of the request with leading "/". Parts starting with a ":" will be interpolated
      # @param params [Hash] params to be included in the query string or interpolated into the url.
      #
      # @return [String]
      #
      def generate_url(path, params={}, options={})
        Hubspot::Config.ensure! :hapikey
        path = path.clone
        params = params.clone
        base_url = options[:base_url] || Hubspot::Config.base_url
        params["hapikey"] = Hubspot::Config.hapikey unless options[:hapikey] == false

        if path =~ /:portal_id/
          Hubspot::Config.ensure! :portal_id
          params["portal_id"] = Hubspot::Config.portal_id if path =~ /:portal_id/
        end

        params.each do |k,v|
          if path.match(":#{k}")
            path.gsub!(":#{k}",v.to_s)
            params.delete(k)
          end
        end
        raise(Hubspot::MissingInterpolation.new("Interpolation not resolved")) if path =~ /:/

        query = params.map do |k,v| 
          v.is_a?(Array) ? v.map { |value| param_string(k,value) } : param_string(k,v) 
        end.join("&")
        
        path += "?" if query.present?
        base_url + path + query
      end

      def converted_value(value)
        if (value.is_a?(Time))
          (value.to_i * 1000) # convert into milliseconds since epoch
        else
          value
        end
      end

      def param_string(key,value)
        if key =~ /range/
          raise "Value must be a range" unless value.is_a?(Range)
          "#{key}=#{converted_value(value.begin)}&#{key}=#{converted_value(value.end)}"
        elsif key =~ /^batch_(.*)$/
          # keys tranformed to accept batch mode syntax
          key = $1.gsub(/(_.)/) { |w| w.last.upcase }
          "#{key}=#{converted_value(value)}"
        else
          "#{key}=#{converted_value(value)}"
        end
      end
    end
  end

  class FormsConnection < Connection
    follow_redirects false

    def self.submit(path, opts)
      url = generate_url(path, opts[:params], { base_url: 'https://forms.hubspot.com' })
      post(url, body: opts[:body].to_json, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
    end
  end      
end