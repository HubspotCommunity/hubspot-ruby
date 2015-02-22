module Hubspot
  #
  # HubSpot Contacts API
  #
  # {https://developers.hubspot.com/docs/methods/contacts/contacts-overview}
  #
  class Contact
    CREATE_CONTACT_PATH = "/contacts/v1/contact"
    GET_CONTACT_BY_EMAIL_PATH = "/contacts/v1/contact/email/:contact_email/profile"
    GET_CONTACT_BY_ID_PATH = "/contacts/v1/contact/vid/:contact_id/profile"
    GET_CONTACT_BY_UTK_PATH = "/contacts/v1/contact/utk/:contact_utk/profile"
    UPDATE_CONTACT_PATH = "/contacts/v1/contact/vid/:contact_id/profile"
    DESTROY_CONTACT_PATH = "/contacts/v1/contact/vid/:contact_id"
    CONTACTS_PATH = "/contacts/v1/lists/all/contacts/all"

    class << self
      # Creates a new contact
      # {https://developers.hubspot.com/docs/methods/contacts/create_contact}
      # @param email [Hash] unique email of the new contact
      # @param params [Hash] hash of properties to set on the contact
      # @return [Hubspot::Contact] the newly created contact
      def create!(email, params={})
        params_with_email = params.stringify_keys.merge("email" => email)
        post_data = {properties: Hubspot::Utils.hash_to_properties(params_with_email)}
        response = Hubspot::Connection.post_json(CREATE_CONTACT_PATH, params: {}, body: post_data )
        new(response)
      end

      # Finds a contact by email
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_by_email}
      # @param email [String] the email of the contact to find
      # @return Hubspot::Contact, the contact found or raises error
      def find_by_email(email)
        response = Hubspot::Connection.get_json(GET_CONTACT_BY_EMAIL_PATH, { contact_email: email })
        new(response)
      end

      # Finds a contact by vid
      # @param vid [String] the vid of the contact to find
      # @return Hubspot::Contact, the contact found or raises error
      def find_by_id(vid)
        response = Hubspot::Connection.get_json(GET_CONTACT_BY_ID_PATH, { contact_id: vid })
        new(response)
      end

      # Finds a contact by its User Token (hubspotutk cookie value)
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_by_utk}
      # @param utk [String] hubspotutk cookie value
      # @return Hubspot::Contact, the contact found or raises error
      def find_by_utk(utk)
        response = Hubspot::Connection.get_json(GET_CONTACT_BY_UTK_PATH, { contact_utk: utk })
        new(response)
      end

      # TODO: Get all contacts
      # {https://developers.hubspot.com/docs/methods/contacts/get_contacts}
      # @param count [Fixnum] number of contacts per page; default 20; max 100
      # @param vidOffset [Fixnum] page through the contacts
      # @return [Hubspot::ContactCollection] the paginated collection of contacts
      def all(opts = {})
        response = Hubspot::Connection.get_json(CONTACTS_PATH, opts)
        response['contacts'].map { |c| new(c) }
      end

      # TODO: Get recently updated and created contacts
      # {https://developers.hubspot.com/docs/methods/contacts/get_recently_updated_contacts}
      # @param count [Fixnum] number of contacts per page; max 100
      # @return [Hubspot::ContactCollection] the paginated collection of contacts
      def recent(count=100)
        raise NotImplementedError
      end

      # TODO: Search for contacts by various crieria
      # {https://developers.hubspot.com/docs/methods/contacts/search_contacts}
      # @param query [String] The search term for what you're searching for
      # @param count [Fixnum] number of contacts per page; max 100
      # @return [Hubspot::ContactCollection] the collection of contacts; no pagination
      def search(query, count=100)
        raise NotImplementedError
      end

      # TODO: Get statistics about all contacts
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_statistics}
      # @return [Hash] hash of statistics
      def statistics
        raise NotImplementedError
      end
    end

    attr_reader :properties
    attr_reader :vid

    def initialize(response_hash)
      @properties = Hubspot::Utils.properties_to_hash(response_hash["properties"])
      @vid = response_hash["vid"]
    end

    def [](property)
      @properties[property]
    end

    def email
      @properties["email"]
    end

    def utk
      @properties["usertoken"]
    end

    # Updates the properties of a contact
    # {https://developers.hubspot.com/docs/methods/contacts/update_contact}
    # @param params [Hash] hash of properties to update
    # @return [Hubspot::Contact] self
    def update!(params)
      query = {"properties" => Hubspot::Utils.hash_to_properties(params.stringify_keys!)}
      response = Hubspot::Connection.post_json(UPDATE_CONTACT_PATH, params: { contact_id: vid }, body: query)
      @properties.merge!(params)
      self
    end

    # Archives the contact in hubspot
    # {https://developers.hubspot.com/docs/methods/contacts/delete_contact}
    # @return [TrueClass] true
    def destroy!
      response = Hubspot::Connection.delete_json(DESTROY_CONTACT_PATH, { contact_id: vid })
      @destroyed = true
    end

    def destroyed?
      !!@destroyed
    end
  end
end
