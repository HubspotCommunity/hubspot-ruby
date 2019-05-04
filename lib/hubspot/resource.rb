module Hubspot
  class Resource

    class_attribute :id_field, instance_writer: false
    class_attribute :property_name_field, instance_writer: false
    class_attribute :update_method, instance_writer: false

    self.id_field = "id"
    self.property_name_field = "property"
    self.update_method = "put"

    class << self
      def from_result(result)
        resource = new(result[id_field])
        resource.send(:initialize_from, result.with_indifferent_access)
        resource
      end

      def find(id)
        instance = new(id)
        instance.reload
      end

      def create(properties = {})
        request = {
          properties: Hubspot::Utils.hash_to_properties(properties.stringify_keys, key_name: property_name_field)
        }
        response = Hubspot::Connection.post_json(create_path, params: {}, body: request)
        from_result(response)
      end

      def update(id, properties = {})
        begin
          update!(id, properties)
        rescue Hubspot::RequestError => e
          false
        end
      end

      def update!(id, properties = {})
        request = {
          properties: Hubspot::Utils.hash_to_properties(properties.stringify_keys, key_name: property_name_field)
        }

        if update_method == "put"
          response = Hubspot::Connection.put_json(update_path, params: { id: id, no_parse: true }, body: request)
        else
          response = Hubspot::Connection.post_json(update_path, params: { id: id, no_parse: true }, body: request)
        end

        response.success?
      end
    end

    def initialize(id_or_properties = nil)
      @changes = HashWithIndifferentAccess.new
      @properties = HashWithIndifferentAccess.new

      if id_or_properties.is_a?(Integer) || id_or_properties.nil?
        @id = id_or_properties
      elsif id_or_properties.is_a?(Hash)
        @id = id_or_properties.delete(id_field) || id_or_properties.delete(:id)

        add_accessors(id_or_properties.keys)
        id_or_properties.each do |k, v|
          send "#{k}=", v
        end
      else
        raise InvalidParams.new("#{self.class.name} must be initialized with an ID, hash, or nil")
      end

      @persisted = @id.present?
      @deleted = false
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

    def changed?
      !@changes.empty?
    end

    def [](name)
      @changes[name] || @properties[name]
    end

    def reload
      raise(Hubspot::InvalidParams.new("Resource must have an ID")) if @id.nil?

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

      if persisted?
        if update_method == "put"
          response = Hubspot::Connection.put_json(update_path, params: { id: @id }, body: request)
        else
          response = Hubspot::Connection.post_json(update_path, params: { id: @id }, body: request)
        end

        update_from_changes
      else
        response = Hubspot::Connection.post_json(create_path, params: {}, body: request)

        # Grab the new ID from the response
        @id = response[id_field]

        # Update the fields with the response
        initialize_from(response.with_indifferent_access)
      end

      @persisted = true
      true
    end

    def update(properties)
      if properties && !properties.is_a?(Hash)
        raise ArgumentError, "When assigning properties, you must pass a hash as an argument."
      end

      @changes = @changes.merge(properties)
      save
    end

    def delete
      raise(Hubspot::InvalidParams.new("Resource must have an ID")) if @id.nil?

      Hubspot::Connection.delete_json(delete_path, id: @id)

      @deleted = true
      @changes = HashWithIndifferentAccess.new
      true
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

    def create_path
      self.class.create_path
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
      @changes = HashWithIndifferentAccess.new
    end

    def update_from_changes
      @changes.each do |k, v|
        @properties[k] ||= {}
        @properties[k]["value"] = v
      end

      # Clear any changes
      @changes = HashWithIndifferentAccess.new
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