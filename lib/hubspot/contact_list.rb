require 'hubspot/utils'
require 'httparty'

# TODO: Refactor all the code generate_url + HTTParty get, post + error raised with a connection class
#       to avoid headers configuration for posts + read as JSON format etc...

module Hubspot
  #
  # HubSpot Contact lists API
  #
  # NOTE: api endpoints not yet implemented:
  # http://developers.hubspot.com/docs/methods/lists/create_list
  # http://developers.hubspot.com/docs/methods/lists/update_list
  # http://developers.hubspot.com/docs/methods/lists/delete_list
  # http://developers.hubspot.com/docs/methods/lists/refresh_list
  class ContactList
    LISTS_PATH = '/contacts/v1/lists'
    LIST_PATH = '/contacts/v1/lists/:list_id'
    LIST_BATCH_PATH = '/contacts/v1/lists/batch'
    CONTACTS_PATH = LIST_PATH + '/contacts/all'
    RECENT_CONTACTS_PATH = LIST_PATH + '/contacts/recent'
    ADD_CONTACT_PATH = LIST_PATH + '/add'
    REMOVE_CONTACT_PATH = LIST_PATH + '/remove'

    class << self
      # {http://developers.hubspot.com/docs/methods/lists/get_lists}
      # {http://developers.hubspot.com/docs/methods/lists/get_static_lists}
      # {http://developers.hubspot.com/docs/methods/lists/get_dynamic_lists}
      def all(opts={})
      	static = opts.delete(:static) { false } 
      	dynamic = opts.delete(:dynamic) { false } 

        # NOTE: As opposed of what the documentation says, getting the static or dynamic lists returns all the list
      	path = LISTS_PATH + (static ? '/static' : dynamic ? '/dynamic' : '') 

        url = Hubspot::Utils.generate_url(path, opts)
        response = HTTParty.get(url, format: :json)

        raise(Hubspot::RequestError.new(response)) unless response.success?
        
        response.parsed_response['lists'].map { |l| new(l) }
      end

      # {http://developers.hubspot.com/docs/methods/lists/get_list}
      # {http://developers.hubspot.com/docs/methods/lists/get_batch_lists}
      def find(ids)
      	batch_mode, path, params = case ids
        when Integer then [false, LIST_PATH, { list_id: ids }]
        when Array then [true, LIST_BATCH_PATH, { batch_list_id: ids }]
      	end

        url = Hubspot::Utils.generate_url(path, params)
        response = HTTParty.get(url, format: :json)

        return nil unless response.success?
        
        if batch_mode
          response.parsed_response['lists'].map { |l| new(l) }
        else
          new(response.parsed_response)
        end
      end
    end

    attr_reader :id
    attr_reader :portal_id
    attr_reader :name
    attr_reader :dynamic
    attr_reader :properties

    def initialize(response_hash)
      @id = response_hash['listId']
      @portal_id = response_hash['portalId']
      @name = response_hash['name']
      @dynamic = response_hash['dynamic']
      @properties = response_hash
    end

    # {http://developers.hubspot.com/docs/methods/lists/get_list_contacts}
    def contacts(opts={})
      # NOTE: caching functionality can be dependant of the nature of the list, if dynamic or not ...
      bypass_cache = opts.delete(:bypass_cache) { false }
      recent = opts.delete(:recent) { false } 

      if bypass_cache || @contacts.nil?
        path = recent ? RECENT_CONTACTS_PATH : CONTACTS_PATH
        opts[:list_id] = @id
      	
        url = Hubspot::Utils.generate_url(path, Hubspot::ContactProperties.add_default_parameters(opts))
        response = HTTParty.get(url, format: :json)

        raise(Hubspot::RequestError.new(response)) unless response.success?

        @contacts = response.parsed_response['contacts'].map { |c| Hubspot::Contact.new(c) }
      else
        @contacts
      end 
    end

    # {http://developers.hubspot.com/docs/methods/lists/add_contact_to_list}
    def add(contacts) 
      contact_ids = [contacts].flatten.uniq.compact.map(&:vid)
      post_data = { vids: contact_ids }

      url = Hubspot::Utils.generate_url(ADD_CONTACT_PATH, { list_id: @id })
      response = HTTParty.post(url, body: post_data.to_json, headers: { 'Content-Type' => 'application/json' }, format: :json)
     
      raise(Hubspot::RequestError.new(response)) unless response.success?

      response = response.parsed_response
      response['updated'].sort == contact_ids.sort
    end
 
    # {http://developers.hubspot.com/docs/methods/lists/remove_contact_from_list}
    def remove(contacts)
      contact_ids = [contacts].flatten.uniq.compact.map(&:vid)
      post_data = { vids: contact_ids }

      url = Hubspot::Utils.generate_url(REMOVE_CONTACT_PATH, { list_id: @id })
      response = HTTParty.post(url, body: post_data.to_json, headers: { 'Content-Type' => 'application/json' }, format: :json)
     
      raise(Hubspot::RequestError.new(response)) unless response.success?

      response = response.parsed_response
      response['updated'].sort == contact_ids.sort
    end
  end
end