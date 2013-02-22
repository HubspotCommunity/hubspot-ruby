require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contacts API
  #
  # {https://developers.hubspot.com/docs/endpoints#contacts-api}
  #
  class Contact
    GET_CONTACT_BY_EMAIL_PATH = "/contacts/v1/contact/email/:contact_email/profile"
    GET_CONTACT_BY_ID_PATH = "/contacts/v1/contact/vid/:contact_id/profile"
    UPDATE_CONTACT_PATH = "/contacts/v1/contact/vid/:contact_id/profile"

    class << self
      # TODO: Creates a new contact
      # {https://developers.hubspot.com/docs/methods/contacts/create_contact}
      # @param email [Hash] unique email of the new contact
      # @param params [Hash] hash of properties to set on the contact
      # @return [Hubspot::Contact] the newly created contact
      def create!(email, params={})
        raise NotImplementedError
      end

      # Finds a contact by email
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_by_email}
      # @param email [String] the email of the contact to find
      # @return [Hubspot::Contact, nil] the contact found or nil
      def find_by_email(email)
        url = Hubspot::Utils.generate_url(GET_CONTACT_BY_EMAIL_PATH, {contact_email: email})
        resp = HTTParty.get(url)
        if resp.code == 200
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
        resp = HTTParty.get(url)
        if resp.code == 200
          Hubspot::Contact.new(resp.parsed_response)
        else
          nil
        end
      end

      # TODO: Finds a contact by its User Token (hubspotutk cookie value)
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_by_utk}
      # @param utk [String] hubspotutk cookie value
      # @return [Hubspot::Contact, nil] the contact found or nil
      def find_by_utk(utk)
        raise NotImplementedError
      end

      # TODO: Get all contacts
      # {https://developers.hubspot.com/docs/methods/contacts/get_contacts}
      # @param count [Fixnum] number of contacts per page; max 100
      # @return [Hubspot::ContactCollection] the paginated collection of contacts
      def all(count=100)
        raise NotImplementedError
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

    # Updates the properties of a contact
    # {https://developers.hubspot.com/docs/methods/contacts/update_contact}
    # @param params [Hash] hash of properties to update
    # @return [Hubspot::Contact] self
    def update!(params)
      params.stringify_keys!
      url = Hubspot::Utils.generate_url(UPDATE_CONTACT_PATH, {contact_id: vid})
      query = {"properties" => Hubspot::Utils.hash_to_properties(params)}
      resp = HTTParty.post(url, body: query.to_json)
      raise(Hubspot::RequestError.new(resp.response)) unless resp.success?
      @properties.merge!(params)
      self
    end

    # TODO: Archives the contact in hubspot
    # {https://developers.hubspot.com/docs/methods/contacts/delete_contact}
    # @return [nil]
    def destroy!
      raise NotImplementedError
    end
  end
end