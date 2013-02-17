module Hubspot
  class ConfigurationError < StandardError; end
  class MissingInterpolation < StandardError; end

  class Utils
    class << self
      # Parses the hubspot properties format into a key-value hash
      def parse_properties(props)
        newprops = {}
        props.each{ |k,v| newprops[k] = v["value"] }
        newprops
      end

      # Generate the API URL for the request
      #
      # @param path [String] The path of the request with leading "/". Parts starting with a ":" will be interpolated
      # @param params [Hash] params to be included in the query string or interpolated into the url.
      #
      # @return [String]
      #
      def generate_url(path, params={})
        raise Hubspot::ConfigurationError.new("'hapikey' not configured") unless Hubspot::Config.hapikey
        params["hapikey"] = Hubspot::Config.hapikey
        ipath = path.clone
        params.each do |k,v|
          if ipath.match(":#{k}")
            ipath.gsub!(":#{k}",v.to_s)
            params.delete(k)
          end
        end
        raise(Hubspot::MissingInterpolation.new("Interpolation not resolved")) if ipath =~ /:/
        query = params.map{ |k,v| "#{k}=#{v}" }.join("&")
        Hubspot::Config.base_url + ipath + "?" + query
      end
    end
  end
end