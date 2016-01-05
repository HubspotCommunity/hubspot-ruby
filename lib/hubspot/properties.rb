module Hubspot
  class Properties

    PROPERTY_SPECS = {
      group_field_names: %w(name displayName displayOrder properties),
      field_names:       %w(name groupName description fieldType formField type displayOrder label options),
      valid_field_types: %w(textarea select text date file number radio checkbox),
      valid_types:       %w(string number bool datetime enumeration),
      options:           %w(description value label hidden displayOrder)
    }

    class << self
      # TODO: properties can be set as configuration
      # TODO: find the way how to set a list of Properties + merge same property key if present from opts
      def add_default_parameters(opts={})
        properties = 'email'
        opts.merge(property: properties)
      end

      def all(path, opts={}, filter={})
        response = Hubspot::Connection.get_json(path, opts)
        filter_results(response, :groupName, filter[:include], filter[:exclude])
      end

      def groups(path, opts={}, filter={})
        response = Hubspot::Connection.get_json(path, opts)
        filter_results(response, :name, filter[:include], filter[:exclude])
      end

      def create!(path, params={})
        post_data = valid_property_params(params)
        return nil if post_data.blank?
        Hubspot::Connection.post_json(path, params: {}, body: post_data)
      end

      def update!(path, property_name, params={})
        post_data = valid_property_params(params)
        return nil if post_data.blank?
        Hubspot::Connection.put_json(path, params: { property_name: property_name }, body: post_data)
      end

      def delete!(path, property_name)
        response = Hubspot::Connection.delete_json(path, property_name: property_name)
        response.parsed_response
      end

      def create_group!(path, params={})
        post_data = valid_group_params(params)
        return nil if post_data.blank?
        Hubspot::Connection.post_json(path, params: {}, body: post_data)
      end

      def update_group!(path, group_name, params={})
        post_data = valid_group_params(params)
        return nil if post_data.blank?
        Hubspot::Connection.put_json(path, params: { group_name: group_name }, body: post_data)
      end

      def delete_group!(path, group_name)
        response = Hubspot::Connection.delete_json(path, group_name: group_name)
        response.parsed_response
      end

      def same?(src, dst)
        src_params = valid_params(src)
        dst_params = valid_params(dst)
        src_params.eql?(dst_params)
        # hash_same?(src_params, dst_params)
      end

      def valid_params(params={})
        valid_property_params(params)
      end

      private

      def filter_results(results, key, include, exclude)
        key = key.to_s
        results.select { |result|
          (include.blank? || include.include?(result[key])) &&
            (exclude.blank? || !exclude.include?(result[key]))
        }
      end

      def valid_property_params(params)
        return {} if params.blank?
        result = params.slice(*PROPERTY_SPECS[:field_names])
        result.delete('fieldType') unless check_field_type(result['fieldType'])
        result.delete('type') unless check_type(result['type'])
        result['options'] = valid_option_params(result['options'])
        result
      end

      def valid_group_params(params)
        return {} if params.blank?
        result = params.slice(*PROPERTY_SPECS[:group_field_names])
        result['properties'] = valid_property_params(result['properties']) unless result['properties'].blank?
        result
      end

      def check_field_type(val)
        return true if PROPERTY_SPECS[:valid_field_types].include?(val)
        puts "Invalid field type: #{val}"
        false
      end

      def check_type(val)
        return true if PROPERTY_SPECS[:valid_types].include?(val)
        puts "Invalid type: #{val}"
        false
      end

      def valid_option_params(options)
        return [] if options.blank?
        options.map { |o| o.slice(*PROPERTY_SPECS[:options]) }
      end

    end
  end
end