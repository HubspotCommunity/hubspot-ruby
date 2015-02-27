require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contact Properties API
  #
  # {http://developers.hubspot.com/docs/methods/contacts/get_properties}
  #
  class ContactProperty
    PROPERTIES_PATH = "/contacts/v1/properties"

    # Class Methods
    class << self
      # Get all properties
      # {http://developers.hubspot.com/docs/methods/contacts/get_properties}
      # @return [Hubspot::ContactPropertyCollection] the paginated collection of
      # contact properties
      def all(opts = {})
        url = Hubspot::Utils.generate_url(PROPERTIES_PATH, opts)
        request = HTTParty.get(url, format: :json)

        raise(Hubspot::RequestError.new(request)) unless request.success?

        found = request.parsed_response
        return found.map{|h| new(h) }
      end

      def create!(properties = {})
        url = Hubspot::Utils.generate_url(PROPERTY_PATH, {name: deal_id})
      end
    end

    attr_accessor :name, :description, :group_name, :type, :field_type,
      :form_field, :display_order, :options

    def initialize(hash)
      # Transform the hash keys into ruby friendly names
      hash = hash.map { |k,v| [k.underscore, v] }.to_h
      # Assign anything we have an accessor for with the same name
      hash.each do |key, value|
        self.send(:"#{key}=", value) if self.respond_to?(:"#{key}=")
      end
    end

  end
end
