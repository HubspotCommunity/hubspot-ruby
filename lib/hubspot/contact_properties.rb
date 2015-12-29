module Hubspot
  class ContactProperties

    ALL_PROPERTIES_PATH  = '/contacts/v2/properties'
    ALL_GROUPS_PATH      = '/contacts/v2/groups'
    CREATE_PROPERTY_PATH = '/contacts/v2/properties/'
    UPDATE_PROPERTY_PATH = '/contacts/v2/properties/named/:property_name'
    DELETE_PROPERTY_PATH = '/contacts/v2/properties/named/:property_name'
    CREATE_GROUP_PATH    = '/contacts/v2/groups/'
    UPDATE_GROUP_PATH    = '/contacts/v2/groups/named/:group_name'
    DELETE_GROUP_PATH    = '/contacts/v2/groups/named/:group_name'

    class << self
      # TODO: properties can be set as configuration
      # TODO: find the way how to set a list of Properties + merge same property key if present from opts
      def add_default_parameters(opts={})
        properties = 'email'
        opts.merge(property: properties)
      end

      def all(opts={}, filter={})
        response = Hubspot::Connection.get_json(ALL_PROPERTIES_PATH, opts)
        filter_results(response, :groupName, filter[:include], filter[:exclude])
      end

      def groups(opts={}, filter={})
        response = Hubspot::Connection.get_json(ALL_GROUPS_PATH, opts)
        filter_results(response, :name, filter[:include], filter[:exclude])
      end

      def create!(params={})
        post_data = params.stringify_keys
        return nil unless valid_property_params(post_data)
        Hubspot::Connection.post_json(CREATE_PROPERTY_PATH, params: {}, body: post_data)
      end

      def update!(property_name, params={})
        post_data = params.stringify_keys
        return nil unless valid_property_params(post_data)
        Hubspot::Connection.put_json(UPDATE_PROPERTY_PATH, params: { property_name: property_name }, body: post_data)
      end

      def delete!(property_name)
        response = Hubspot::Connection.delete_json(DELETE_PROPERTY_PATH, property_name: property_name)
        response.parsed_response
      end

      def create_group!(params={})
        post_data = params.stringify_keys
        return nil unless valid_group_params(post_data)
        Hubspot::Connection.post_json(CREATE_GROUP_PATH, params: {}, body: post_data)
      end

      def update_group!(group_name, params={})
        # PUT
        post_data = params.stringify_keys
        return nil unless valid_group_params(post_data)
        Hubspot::Connection.put_json(UPDATE_GROUP_PATH, params: { group_name: group_name }, body: post_data)
      end

      def delete_group!(group_name)
        response = Hubspot::Connection.delete_json(DELETE_GROUP_PATH, group_name: group_name)
        response.parsed_response
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
        names             = %w(name groupName description fieldType formField type displayOrder label options)
        valid_field_types = %w(textarea select text date file number radio checkbox)
        valid_types       = %w(string number bool datetime enumeration)

        params.each do |key, val|
          return false unless names.include?(key)
          return false if key == 'fieldType' && !valid_field_types.include?(val)
          return false if key == 'type' && !valid_types.include?(val)
        end
        true
      end

      def valid_group_params(params)
        names = %w(name displayName displayOrder properties)
        params.each do |key, val|
          return false unless names.include?(key)
          return false if key == 'properties' && !valid_property_params(val)
        end
      end

    end

  end
end