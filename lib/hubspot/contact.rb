require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contacts API
  #
  # {https://developers.hubspot.com/docs/endpoints#contacts-api}
  #
  class Contact
    CREATE_CONTACT_PATH = "/contacts/v1/contact"
    GET_CONTACT_BY_EMAIL_PATH = "/contacts/v1/contact/email/:contact_email/profile"
    GET_CONTACT_BY_ID_PATH = "/contacts/v1/contact/vid/:contact_id/profile"
    GET_CONTACT_BY_UTK_PATH = "/contacts/v1/contact/utk/:contact_utk/profile"
    GET_CONTACTS_PATH = "/contacts/v1/lists/all/contacts/all"
    UPDATE_CONTACT_PATH = "/contacts/v1/contact/vid/:contact_id/profile"
    DESTROY_CONTACT_PATH = "/contacts/v1/contact/vid/:contact_id"

    class << self
      # Creates a new contact
      # {https://developers.hubspot.com/docs/methods/contacts/create_contact}
      # @param email [Hash] unique email of the new contact
      # @param params [Hash] hash of properties to set on the contact
      # @return [Hubspot::Contact] the newly created contact
      def create!(email, params={})
        params_with_email = params.stringify_keys.merge("email" => email)
        url = Hubspot::Utils.generate_url(CREATE_CONTACT_PATH)
        post_data = {properties: Hubspot::Utils.hash_to_properties(params_with_email)}
        resp = HTTParty.post(url, body: post_data.to_json, format: :json)
        raise(Hubspot::ContactExistsError.new(resp, "Contact already exists with email: #{email}")) if resp.code == 409
        raise(Hubspot::RequestError.new(resp, "Cannot create contact with email: #{email}")) unless resp.success?
        Hubspot::Contact.new(resp.parsed_response)
      end

      # Finds a contact by email
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_by_email}
      # @param email [String] the email of the contact to find
      # @return [Hubspot::Contact, nil] the contact found or nil
      def find_by_email(email)
        url = Hubspot::Utils.generate_url(GET_CONTACT_BY_EMAIL_PATH, {contact_email: email})
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          Hubspot::Contact.new(resp.parsed_response)
        else
          nil
        end
      end

      # Finds a contact by vid
      # @param vid [String] the vid of the contact to find
      # @return [Hubspot::Contact, nil] the contact found or nil
      def find_by_id(vid)
        url = Hubspot::Utils.generate_url(GET_CONTACT_BY_ID_PATH, {contact_id: vid})
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          Hubspot::Contact.new(resp.parsed_response)
        else
          nil
        end
      end

      # Finds a contact by its User Token (hubspotutk cookie value)
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_by_utk}
      # @param utk [String] hubspotutk cookie value
      # @return [Hubspot::Contact, nil] the contact found or nil
      def find_by_utk(utk)
        url = Hubspot::Utils.generate_url(GET_CONTACT_BY_UTK_PATH, {contact_utk: utk})
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          Hubspot::Contact.new(resp.parsed_response)
        else
          nil
        end
      end

      # Get all contacts
      # {https://developers.hubspot.com/docs/methods/contacts/get_contacts}
      # @param [Hash] Options for contact fetching
      # @option params [Integer] :count number of contacts per page; max 100
      # @option params [Array] :property set of properties to retrieve per contact
      # @option params [Integer] :vid_offset Offset # for paginating requests
      # @return [Hash] collection with :contacts, :has_more, and :vid_offset keys
      def all(params={})
        params['vidOffset'] = params.delete(:vid_offset) if params[:vid_offset]
        url = Hubspot::Utils.generate_url(GET_CONTACTS_PATH, params)
        resp = HTTParty.get(url, format: :json)
        if resp.success?
          {
            contacts: resp['contacts'].map { |c| Hubspot::Contact.new(c) },
            has_more: resp['has-more'],
            vid_offset: resp['vid-offset']
          }
        else
          nil
        end
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
      params.stringify_keys!
      url = Hubspot::Utils.generate_url(UPDATE_CONTACT_PATH, {contact_id: vid})
      query = {"properties" => Hubspot::Utils.hash_to_properties(params)}
      resp = HTTParty.post(url, body: query.to_json, format: :json)
      raise(Hubspot::RequestError.new(resp)) unless resp.success?
      @properties.merge!(params)
      self
    end

    # Archives the contact in hubspot
    # {https://developers.hubspot.com/docs/methods/contacts/delete_contact}
    # @return [TrueClass] true
    def destroy!
      url = Hubspot::Utils.generate_url(DESTROY_CONTACT_PATH, {contact_id: vid})
      resp = HTTParty.delete(url, format: :json)
      raise(Hubspot::RequestError.new(resp)) unless resp.success?
      @destroyed = true
    end

    def destroyed?
      !!@destroyed
    end
  end
end