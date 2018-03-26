module Hubspot
  #
  # HubSpot Contacts API
  #
  # {https://developers.hubspot.com/docs/methods/contacts/contacts-overview}
  #
  # TODO: work on all endpoints that can specify contact properties, property mode etc... as params. cf pending specs
  class Contact
    CREATE_CONTACT_PATH          = '/contacts/v1/contact'
    BATCH_CREATE_OR_UPDATE_PATH  = '/contacts/v1/contact/batch/'
    GET_CONTACT_BY_EMAIL_PATH    = '/contacts/v1/contact/email/:contact_email/profile'
    GET_CONTACTS_BY_EMAIL_PATH   = '/contacts/v1/contact/emails/batch'
    GET_CONTACT_BY_ID_PATH       = '/contacts/v1/contact/vid/:contact_id/profile'
    CONTACT_BATCH_PATH           = '/contacts/v1/contact/vids/batch'
    GET_CONTACT_BY_UTK_PATH      = '/contacts/v1/contact/utk/:contact_utk/profile'
    GET_CONTACTS_BY_UTK_PATH     = '/contacts/v1/contact/utks/batch'
    UPDATE_CONTACT_PATH          = '/contacts/v1/contact/vid/:contact_id/profile'
    DESTROY_CONTACT_PATH         = '/contacts/v1/contact/vid/:contact_id'
    CONTACTS_PATH                = '/contacts/v1/lists/all/contacts/all'
    RECENTLY_UPDATED_PATH        = '/contacts/v1/lists/recently_updated/contacts/recent'
    RECENTLY_CREATED_PATH        = '/contacts/v1/lists/all/contacts/recent'
    CREATE_OR_UPDATE_PATH        = '/contacts/v1/contact/createOrUpdate/email/:contact_email'
    QUERY_PATH                   = '/contacts/v1/search/query'

    class << self
      # {https://developers.hubspot.com/docs/methods/contacts/create_contact}
      def create!(email, params={})
        params_with_email = params.stringify_keys
        params_with_email = params.stringify_keys.merge('email' => email) if email
        post_data = {properties: Hubspot::Utils.hash_to_properties(params_with_email)}
        response = Hubspot::Connection.post_json(CREATE_CONTACT_PATH, params: {}, body: post_data )
        new(response)
      end

      # {https://developers.hubspot.com/docs/methods/contacts/get_contacts}
      # {https://developers.hubspot.com/docs/methods/contacts/get_recently_updated_contacts}
      # {https://developers.hubspot.com/docs/methods/contacts/get_recently_created_contacts}
      def all(opts={})
        recent = opts.delete(:recent) { false }
        recent_created = opts.delete(:recent_created) { false }
        paged = opts.delete(:paged) { false }
        path, opts =
        if recent_created
          [RECENTLY_CREATED_PATH, Hubspot::ContactProperties.add_default_parameters(opts)]
        elsif recent
          [RECENTLY_UPDATED_PATH, Hubspot::ContactProperties.add_default_parameters(opts)]
        else
          [CONTACTS_PATH, opts]
        end

        response = Hubspot::Connection.get_json(path, opts)
        response['contacts'].map! { |c| new(c) }
        paged ? response : response['contacts']
      end

      # TODO: create or update a contact
      # PATH /contacts/v1/contact/createOrUpdate/email/:contact_email
      # API endpoint: https://developers.hubspot.com/docs/methods/contacts/create_or_update
      def createOrUpdate(email, params={})
        post_data = {properties: Hubspot::Utils.hash_to_properties(params.stringify_keys)}
        response = Hubspot::Connection.post_json(CREATE_OR_UPDATE_PATH, params: { contact_email: email }, body: post_data )
        contact = find_by_id(response['vid'])
        contact.is_new = response['isNew']
        contact
      end

      # NOTE: Performance is best when calls are limited to 100 or fewer contacts
      # {https://developers.hubspot.com/docs/methods/contacts/batch_create_or_update}
      def create_or_update!(contacts)
        query = contacts.map do |ch|
          contact_hash = ch.with_indifferent_access
          if contact_hash[:vid]
            contact_param = {
              vid: contact_hash[:vid],
              properties: Hubspot::Utils.hash_to_properties(contact_hash.except(:vid))
            }
          elsif contact_hash[:email]
            contact_param = {
              email: contact_hash[:email],
              properties: Hubspot::Utils.hash_to_properties(contact_hash.except(:email))
            }
          else
            raise Hubspot::InvalidParams, 'expecting vid or email for contact'
          end
          contact_param
        end
        Hubspot::Connection.post_json(BATCH_CREATE_OR_UPDATE_PATH,
                                      params: {},
                                      body: query)
      end

      # NOTE: problem with batch api endpoint
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact}
      # {https://developers.hubspot.com/docs/methods/contacts/get_batch_by_vid}
      def find_by_id(vids)
        batch_mode, path, params = case vids
        when Integer then [false, GET_CONTACT_BY_ID_PATH, { contact_id: vids }]
        when Array then [true, CONTACT_BATCH_PATH, { batch_vid: vids }]
        else raise Hubspot::InvalidParams, 'expecting Integer or Array of Integers parameter'
        end

        response = Hubspot::Connection.get_json(path, params)
        raise Hubspot::ApiError if batch_mode
        new(response)
      end

      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_by_email}
      # {https://developers.hubspot.com/docs/methods/contacts/get_batch_by_email}
      def find_by_email(emails)
        batch_mode, path, params = case emails
        when String then [false, GET_CONTACT_BY_EMAIL_PATH, { contact_email: emails }]
        when Array then [true, GET_CONTACTS_BY_EMAIL_PATH, { batch_email: emails }]
        else raise Hubspot::InvalidParams, 'expecting String or Array of Strings parameter'
        end

        begin
          response = Hubspot::Connection.get_json(path, params)
          if batch_mode
            response.map{|_, contact| new(contact)}
          else
            new(response)
          end
        rescue => e
          raise e unless e.message =~ /not exist/ # 404 / handle the error and kindly return nil
          nil
        end
      end

      # NOTE: problem with batch api endpoint
      # {https://developers.hubspot.com/docs/methods/contacts/get_contact_by_utk}
      # {https://developers.hubspot.com/docs/methods/contacts/get_batch_by_utk}
      def find_by_utk(utks)
        batch_mode, path, params = case utks
        when String then [false, GET_CONTACT_BY_UTK_PATH, { contact_utk: utks }]
        when Array then [true, GET_CONTACTS_BY_UTK_PATH, { batch_utk: utks }]
        else raise Hubspot::InvalidParams, 'expecting String or Array of Strings parameter'
        end

        response = Hubspot::Connection.get_json(path, params)
        raise Hubspot::ApiError if batch_mode
        new(response)
      end

      # {https://developers.hubspot.com/docs/methods/contacts/search_contacts}
      def search(query, options = {})
        count   = options.fetch(:count, 100)
        offset  = options.fetch(:offset, 0)

        response = Hubspot::Connection.get_json(QUERY_PATH, { q: query, count: count, offset: offset })
        response.merge("contacts" => response["contacts"].map { |contact_hash| new(contact_hash) })
      end
    end

    attr_reader :properties, :vid, :is_new
    attr_reader :is_contact, :list_memberships

    def initialize(response_hash)
      props = response_hash['properties']
      @properties = Hubspot::Utils.properties_to_hash(props) unless props.blank?
      @is_contact = response_hash["is-contact"]
      @list_memberships = response_hash["list-memberships"] || []
      @vid = response_hash['vid']
    end

    def [](property)
      @properties[property]
    end

    def email
      @properties['email']
    end

    def utk
      @properties['usertoken']
    end

    def is_new=(val)
      @is_new = val
    end

    # Updates the properties of a contact
    # {https://developers.hubspot.com/docs/methods/contacts/update_contact}
    # @param params [Hash] hash of properties to update
    # @return [Hubspot::Contact] self
    def update!(params)
      query = {"properties" => Hubspot::Utils.hash_to_properties(params.stringify_keys!)}
      Hubspot::Connection.post_json(UPDATE_CONTACT_PATH, params: { contact_id: vid }, body: query)
      @properties.merge!(params)
      self
    end

    # Archives the contact in hubspot
    # {https://developers.hubspot.com/docs/methods/contacts/delete_contact}
    # @return [TrueClass] true
    def destroy!
      Hubspot::Connection.delete_json(DESTROY_CONTACT_PATH, { contact_id: vid })
      @destroyed = true
    end

    def destroyed?
      !!@destroyed
    end
  end
end
