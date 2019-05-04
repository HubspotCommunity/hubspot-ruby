module Hubspot
  class Connection
    include HTTParty

    class << self
      def get_json(path, opts)
        url = generate_url(path, opts)
        response = get(url, format: :json, read_timeout: read_timeout(opts), open_timeout: open_timeout(opts))
        log_request_and_response url, response
        handle_response(response)
      end

      def post_json(path, opts)
        no_parse = opts[:params].delete(:no_parse) { false }

        url = generate_url(path, opts[:params])
        response = post(
          url,
          body: opts[:body].to_json,
          headers: { 'Content-Type' => 'application/json' },
          format: :json,
          read_timeout: read_timeout(opts),
          open_timeout: open_timeout(opts)
        )

        log_request_and_response url, response, opts[:body]
        raise(Hubspot::RequestError.new(response)) unless response.success?

        no_parse ? response : response.parsed_response
      end

      def put_json(path, options)
        no_parse = options[:params].delete(:no_parse) { false }
        url = generate_url(path, options[:params])

        response = put(
          url,
          body: options[:body].to_json,
          headers: { "Content-Type" => "application/json" },
          format: :json,
          read_timeout: read_timeout(options),
          open_timeout: open_timeout(options),
        )

        log_request_and_response(url, response, options[:body])
        raise(Hubspot::RequestError.new(response)) unless response.success?

        no_parse ? response : response.parsed_response
      end

      def delete_json(path, opts)
        url = generate_url(path, opts)
        response = delete(url, format: :json, read_timeout: read_timeout(opts), open_timeout: open_timeout(opts))
        log_request_and_response url, response, opts[:body]
        raise(Hubspot::RequestError.new(response)) unless response.success?
        response
      end

      protected

      def read_timeout(opts = {})
        opts.delete(:read_timeout) || Hubspot::Config.read_timeout
      end

      def open_timeout(opts = {})
        opts.delete(:open_timeout) || Hubspot::Config.open_timeout
      end

      def handle_response(response)
        if response.success?
          response.parsed_response
        else
          raise(Hubspot::RequestError.new(response))
        end
      end

      def log_request_and_response(uri, response, body=nil)
        Hubspot::Config.logger.info(<<~MSG)
          Hubspot: #{uri}.
          Body: #{body}.
          Response: #{response.code} #{response.body}
        MSG
      end

      def generate_url(path, params={}, options={})
        if Hubspot::Config.access_token.present?
          options[:hapikey] = false
        else
          Hubspot::Config.ensure! :hapikey
        end
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
            path.gsub!(":#{k}", CGI.escape(v.to_s))
            params.delete(k)
          end
        end
        raise(Hubspot::MissingInterpolation.new("Interpolation not resolved")) if path =~ /:/

        query = params.map do |k,v|
          v.is_a?(Array) ? v.map { |value| param_string(k,value) } : param_string(k,v)
        end.join("&")

        path += path.include?('?') ? '&' : "?" if query.present?
        base_url + path + query
      end

      # convert into milliseconds since epoch
      def converted_value(value)
        value.is_a?(Time) ? (value.to_i * 1000) : CGI.escape(value.to_s)
      end

      def param_string(key,value)
        case key
        when /range/
          raise "Value must be a range" unless value.is_a?(Range)
          "#{key}=#{converted_value(value.begin)}&#{key}=#{converted_value(value.end)}"
        when /^batch_(.*)$/
          key = $1.gsub(/(_.)/) { |w| w.last.upcase }
          "#{key}=#{converted_value(value)}"
        else
          "#{key}=#{converted_value(value)}"
        end
      end
    end
  end

  class FormsConnection < Connection
    follow_redirects true

    def self.submit(path, opts)
      url = generate_url(path, opts[:params], { base_url: 'https://forms.hubspot.com', hapikey: false })
      post(url, body: opts[:body], headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
    end
  end
end
