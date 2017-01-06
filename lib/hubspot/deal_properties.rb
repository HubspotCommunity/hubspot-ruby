module Hubspot
  class DealProperties < Properties

    ALL_PROPERTIES_PATH  = '/deals/v1/properties'
    ALL_GROUPS_PATH      = '/deals/v1/groups'
    CREATE_PROPERTY_PATH = '/deals/v1/properties/'
    UPDATE_PROPERTY_PATH = '/deals/v1/properties/named/:property_name'
    DELETE_PROPERTY_PATH = '/deals/v1/properties/named/:property_name'
    CREATE_GROUP_PATH    = '/deals/v1/groups/'
    UPDATE_GROUP_PATH    = '/deals/v1/groups/named/:group_name'
    DELETE_GROUP_PATH    = '/deals/v1/groups/named/:group_name'

    class << self
      def add_default_parameters(opts={})
        superclass.add_default_parameters(opts)
      end

      def all(opts={}, filter={})
        superclass.all(ALL_PROPERTIES_PATH, opts, filter)
      end

      def groups(opts={}, filter={})
        superclass.groups(ALL_GROUPS_PATH, opts, filter)
      end

      def create!(params={})
        superclass.create!(CREATE_PROPERTY_PATH, params)
      end

      def update!(property_name, params={})
        superclass.update!(UPDATE_PROPERTY_PATH, property_name, params)
      end

      def delete!(property_name)
        superclass.delete!(DELETE_PROPERTY_PATH, property_name)
      end

      def create_group!(params={})
        superclass.create_group!(CREATE_GROUP_PATH, params)
      end

      def update_group!(group_name, params={})
        superclass.update_group!(UPDATE_GROUP_PATH, group_name, params)
      end

      def delete_group!(group_name)
        superclass.delete_group!(DELETE_GROUP_PATH, group_name)
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
