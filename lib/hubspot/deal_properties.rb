module Hubspot
  class DealProperties

    ALL_PROPERTIES_PATH  = '/deals/v1/properties'
    ALL_GROUPS_PATH      = '/deals/v1/groups'
    CREATE_PROPERTY_PATH = '/deals/v1/properties/'
    UPDATE_PROPERTY_PATH = '/deals/v1/properties/named/:property_name'
    DELETE_PROPERTY_PATH = '/deals/v1/properties/named/:property_name'
    CREATE_GROUP_PATH    = '/deals/v1/groups/'
    UPDATE_GROUP_PATH    = '/deals/v1/groups/named/:group_name'
    DELETE_GROUP_PATH    = '/deals/v1/groups/named/:group_name'

    PROPERTY_SPECS = {
      group_field_names: %w(name displayName displayOrder properties),
      field_names:       %w(name groupName description fieldType formField type displayOrder label options),
      valid_field_types: %w(textarea select text date file number radio checkbox),
      valid_types:       %w(string number bool datetime enumeration)
    }

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
        post_data = valid_property_params(params)
        return nil if post_data.blank?
        Hubspot::Connection.post_json(CREATE_PROPERTY_PATH, params: {}, body: post_data)
      end

      def update!(property_name, params={})
        post_data = valid_property_params(params)
        return nil if post_data.blank?
        Hubspot::Connection.put_json(UPDATE_PROPERTY_PATH, params: { property_name: property_name }, body: post_data)
      end

      def delete!(property_name)
        response = Hubspot::Connection.delete_json(DELETE_PROPERTY_PATH, property_name: property_name)
        response.parsed_response
      end

      def create_group!(params={})
        post_data = valid_group_params(params)
        return nil if post_data.blank?
        Hubspot::Connection.post_json(CREATE_GROUP_PATH, params: {}, body: post_data)
      end

      def update_group!(group_name, params={})
        post_data = valid_group_params(params)
        return nil if post_data.blank?
        Hubspot::Connection.put_json(UPDATE_GROUP_PATH, params: { group_name: group_name }, body: post_data)
      end

      def delete_group!(group_name)
        response = Hubspot::Connection.delete_json(DELETE_GROUP_PATH, group_name: group_name)
        response.parsed_response
      end

      def same?(src, dst)
        valid_property_params(src).eql?(valid_property_params(dst))
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
        params.select { |key, val|
          if PROPERTY_SPECS[:field_names].include?(key)
            case key
              when 'fieldType'
                check_field_type(val)
              when 'type'
                check_type(val)
              else
                true
            end
          end
        }
      end

      def valid_group_params(params)
        params.select do |key, val|
          if PROPERTY_SPECS[:group_field_names].include?(key)
            case key
              when 'properties'
                valid_property_params(val)
              else
                true
            end
          end
        end
      end

      def check_field_type(val)
        return true if PROPERTY_SPECS[:valid_field_types].include?(val)
        puts "Invalid field type: #{val}"
        nil
      end

      def check_type(val)
        return true if PROPERTY_SPECS[:valid_types].include?(val)
        puts "Invalid type: #{val}"
        nil
      end

    end
  end
end