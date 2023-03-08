module Hubspot
  class ContactProperties < Properties

    ALL_PROPERTIES_PATH  = '/contacts/v2/properties'
    ALL_GROUPS_PATH      = '/contacts/v2/groups'
    CREATE_PROPERTY_PATH = '/contacts/v2/properties/'
    UPDATE_PROPERTY_PATH = '/contacts/v2/properties/named/:property_name'
    DELETE_PROPERTY_PATH = '/contacts/v2/properties/named/:property_name'
    CREATE_GROUP_PATH    = '/contacts/v2/groups/'
    UPDATE_GROUP_PATH    = '/contacts/v2/groups/named/:group_name'
    DELETE_GROUP_PATH    = '/contacts/v2/groups/named/:group_name'

    class << self
      def add_default_parameters(opts={})
        superclass.add_default_parameters(opts)
      end

      def all(connection, opts={}, filter={})
        superclass.all(connection, ALL_PROPERTIES_PATH, opts, filter)
      end

      def groups(connection, opts={}, filter={})
        superclass.groups(connection, ALL_GROUPS_PATH, opts, filter)
      end

      def create!(connection, params={})
        superclass.create!(connection, CREATE_PROPERTY_PATH, params)
      end

      def update!(connection, property_name, params={})
        superclass.update!(connection, UPDATE_PROPERTY_PATH, property_name, params)
      end

      def delete!(connection, property_name)
        superclass.delete!(connection, DELETE_PROPERTY_PATH, property_name)
      end

      def create_group!(connection, params={})
        superclass.create_group!(connection, CREATE_GROUP_PATH, params)
      end

      def update_group!(connection, group_name, params={})
        superclass.update_group!(connection, UPDATE_GROUP_PATH, group_name, params)
      end

      def delete_group!(connection, group_name)
        superclass.delete_group!(connection, DELETE_GROUP_PATH, group_name)
      end

      def same?(src, dst)
        superclass.same?(src, dst)
      end

      def valid_params(params)
        superclass.valid_params(params)
      end
    end
  end
end
