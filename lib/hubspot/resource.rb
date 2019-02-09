module Hubspot
  class Resource

    class_attribute :id_field, instance_writer: false, default: "id"
    class_attribute :property_name_field, instance_writer: false, default: "property"
    class_attribute :update_method, instance_writer: false, default: "put"

    class << self
      def find(id)
        instance = new(id)
        instance.reload
      end

      def create(properties = {})
        request = {
          properties: Hubspot::Utils.hash_to_properties(properties.stringify_keys, key_name: property_name_field)
        }
        response = Hubspot::Connection.post_json(create_path, params: {}, body: request)
        new(response)
      end
    end

    def initialize(id_or_response = nil)
      if id_or_response.is_a?(Integer) || id_or_response.nil?
        @id = id_or_response
        initialize_from(HashWithIndifferentAccess.new)
      elsif id_or_response.is_a?(Hash)
        @id = id_or_response[id_field]
        initialize_from(id_or_response.with_indifferent_access)
      else
        raise InvalidParams.new("#{self.class.name} must be initialized with an ID, hash, or nil")
      end

      @persisted = @id.present?
      @deleted = false
      @changes = {}
    end

    def id
      @id
    end

    def id=(id)
      @id = id
    end

    def to_i
      @id
    end

    def metadata
      @metadata
    end

    def changes
      @changes
    end

    def [](name)
      @properties[name]
    end

    def reload
      response = Hubspot::Connection.get_json(find_path, id: @id)
      initialize_from(response.with_indifferent_access)

      self
    end

    def persisted?
      @persisted
    end

    def save
      request = {
        properties: Hubspot::Utils.hash_to_properties(@changes.stringify_keys, key_name: property_name_field)
      }
      if update_method == "put"
        Hubspot::Connection.put_json(update_path, params: { id: @id }, body: request)
      else
        Hubspot::Connection.post_json(update_path, params: { id: @id }, body: request)
      end

      modifications = @changes.inject({}) { |h, (k, v)| h.merge(k => {"value" => v}) }
      @properties = @properties.deep_merge(modifications)
      @changes = {}

      self
    end

    def delete
      Hubspot::Connection.delete_json(delete_path, id: @id)

      @deleted = true
      @changes = {}
      self
    end

    def deleted?
      @deleted
    end

  protected

    def self.create_path
      begin
        self::CREATE_PATH
      rescue NameError
        raise "CREATE_PATH not defined for #{self.class.name}"
      end
    end

    def self.find_path
      begin
        self::FIND_PATH
      rescue NameError
        raise "FIND_PATH not defined for #{self.class.name}"
      end
    end

    def find_path
      self.class.find_path
    end

    def self.update_path
      begin
        self::UPDATE_PATH
      rescue NameError
        raise "UPDATE_PATH not defined for #{self.class.name}"
      end
    end

    def update_path
      self.class.update_path
    end

    def self.delete_path
      begin
        self::DELETE_PATH
      rescue NameError
        raise "CREATE_PATH not defined for #{self.class.name}"
      end
    end

    def delete_path
      self.class.delete_path
    end

    def initialize_from(response)
      @properties = response["properties"] || HashWithIndifferentAccess.new
      @metadata = response.except "properties"

      add_accessors(@properties.keys)

      # Clear any changes
      @changes = {}
    end

    def add_accessors(keys)
      singleton_class.instance_eval do
        keys.each do |k|
          # Define a getter
          define_method(k) { @changes[k.to_sym] || @properties.dig(k, "value") }

          # Define a setter
          define_method("#{k}=") do |v|
            @changes[k.to_sym] = v
          end
        end
      end
    end

    def method_missing(method_name, *arguments, &block)
      # When assigning a missing attribute define the accessors and set the value
      if method_name.to_s.end_with?("=")
        attr = method_name.to_s[0...-1].to_sym
        add_accessors([attr])

        # Call the new setter
        return send(method_name, arguments[0])
      elsif @properties.key?(method_name)
        return @properties[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      (@properties && @properties.key?(method_name)) || super
    end
  end
end