require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contacts API
  #
  # {https://developers.hubspot.com/docs/endpoints#contacts-api}
  #
  class Deal

    attr_reader :properties
    attr_reader :portal_id
    attr_reader :deal_id

    def initialize(response_hash)
      @portal_id = response_hash["portalId"]
      @deal_id = response_hash["dealId"]
      @properties = Hubspot::Utils.properties_to_hash(response_hash["properties"])
    end
  end
end
