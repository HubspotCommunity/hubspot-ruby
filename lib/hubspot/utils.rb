module Hubspot
  class Utils
    class << self
      # Parses the hubspot properties format into a key-value hash
      def properties_to_hash(props)
        newprops = {}
        props.each{ |k,v| newprops[k] = v["value"] }
        newprops
      end

      # Turns a hash into the hubspot properties format
      def hash_to_properties(hash)
        hash.map{ |k,v| {"property" => k.to_s, "value" => v}}
      end

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
        query = params.map{ |k,v| "#{k}=#{v}" }.join("&")
        path += "?" if query.present?
        base_url + path + query
      end
    end
  end
end