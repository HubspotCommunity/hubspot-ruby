require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Deal Properties API
  #
  # {http://developers.hubspot.com/docs/methods/deals/get_properties}
  #
  class DealProperty < Property
    PROPERTIES_PATH = "/deals/v1/properties"
    PROPERTY_PATH   = "/deals/v1/properties/:name"

    # Class Methods
    class << self
      def collection_path; PROPERTIES_PATH; end
      def instance_path;   PROPERTIES_PATH; end
    end

  end

end
