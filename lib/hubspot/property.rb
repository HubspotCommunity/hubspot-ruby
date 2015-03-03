require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contact Properties API
  #
  # {http://developers.hubspot.com/docs/methods/contacts/get_properties}
  #
  class Property

    # Class Methods
    class << self
      # Get all properties
      # {http://developers.hubspot.com/docs/methods/contacts/get_properties}
      # @return [Hubspot::PropertyCollection] the paginated collection of
      # properties
      def all(opts = {})
        url = Hubspot::Utils.generate_url(collection_path, opts)
        request = HTTParty.get(url, format: :json)

        raise(Hubspot::RequestError.new(request)) unless request.success?

        found = request.parsed_response
        return found.map{|h| new(h) }
      end

      # Creates a new Property
      # {http://developers.hubspot.com/docs/methods/contacts/create_property}
      # @return [Hubspot::Property] the created property
      # @raise [Hubspot::PropertyExistsError] if a property already exists with the given name
      # @raise [Hubspot::RequestError] if the creation fails
      def create!(name, params = {})
        name = name.to_s.camelize(:lower)
        # Merge the name with the rest of the params
        params_with_name = params.stringify_keys.merge("name" => name)
        # Merge in sensible defaults so we don't have to specify everything
        params_with_name.reverse_merge! default_creation_params
        # Transform keys to Hubspot's camelcase format
        params_with_name = Hubspot::Utils.camelize_hash(params_with_name)
        url  = Hubspot::Utils.generate_url(creation_path, {name: name})
        resp = HTTParty.send(create_method, url, body: params_with_name.to_json, format: :json,
          headers: {"Content-Type" => "application/json"})
        raise(Hubspot::PropertyExistsError.new(resp, "#{self.name} already exists with name: #{name}")) if resp.code == 409
        raise(Hubspot::RequestError.new(resp, "Cannot create #{self.name} with name: #{name}")) unless resp.success?
        new(resp.parsed_response)
      end

      # Sometimes it's easier to delete things by name than instantiating them
      def destroy!(name)
        name = name.to_s.camelize(:lower)
        url = Hubspot::Utils.generate_url(deletion_path, {name: name})
        resp = HTTParty.delete(url, format: :json)
        raise(Hubspot::RequestError.new(resp)) unless resp.success?
        true
      end

      protected

      def create_method
        :post
      end

      def collection_path
        raise NotImplementedError
      end

      def instance_path
        raise NotImplementedError
      end

      def creation_path
        collection_path
      end

      def deletion_path
        instance_path
      end

      def default_creation_params
        {
          "description"   => "",
          "group_name"    => "contactinformation",
          "type"          => "string",
          "field_type"    => "text",
        }
      end
    end

    delegate :instance_path, to: :class

    attr_accessor :name, :description, :group_name, :type, :field_type,
      :form_field, :display_order, :options

    def initialize(hash)
      # Transform hubspot keys into ruby friendly names
      hash = Hubspot::Utils.underscore_hash(hash)
      # Assign anything we have an accessor for with the same name
      hash.each do |key, value|
        self.send(:"#{key}=", value) if self.respond_to?(:"#{key}=")
      end
    end

    # Archives the contact property in hubspot
    # {http://developers.hubspot.com/docs/methods/contacts/delete_property}
    # @return [TrueClass] true
    def destroy!
      @destroyed = self.class.destroy! self.name
    end

    def destroyed?
      !!@destroyed
    end

  end
end
