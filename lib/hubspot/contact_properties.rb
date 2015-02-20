require 'hubspot/utils'
require 'httparty'

module Hubspot
  class ContactProperties
    class << self    
      # TODO: properties can be set as configuration
      # TODO: find the way how to set a list of Properties + merge same property key if present from opts
      def add_default_parameters(opts={})
        properties = 'email'
        opts.merge(property: properties)
      end
    end
  end
end