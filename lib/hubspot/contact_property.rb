require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contact Properties API
  #
  # {http://developers.hubspot.com/docs/methods/contacts/get_properties}
  class ContactProperty < Property
    PROPERTIES_PATH = "/contacts/v1/properties"
    PROPERTY_PATH   = "/contacts/v1/properties/:name"

    class << self
      protected

      def collection_path; PROPERTIES_PATH; end
      def instance_path;   PROPERTY_PATH;   end

      # Only for ContactProperties the creation is a put instead of a post (facepalm)
      def create_method
        :put
      end

      def creation_path
        instance_path
      end
    end

  end

end
