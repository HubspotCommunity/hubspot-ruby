require 'hubspot/utils'
require 'httparty'

module Hubspot
  #
  # HubSpot Contact lists API
  #
  class ContactList
    LISTS_PATH = '/contacts/v1/lists'
    LIST_PATH = '/contacts/v1/lists/:list_id'
    CONTACTS_PATH = LIST_PATH + '/contacts/all'
    RECENT_CONTACTS_PATH = LIST_PATH + '/contacts/recent'

    class << self
      # {http://developers.hubspot.com/docs/methods/lists/get_lists}
      def all(opts={})
        url = Hubspot::Utils.generate_url(LISTS_PATH, opts)
        response = HTTParty.get(url, format: :json)

        raise(Hubspot::RequestError.new(response)) unless response.success?
        
        response.parsed_response['lists'].map { |l| new(l) }
      end

      # {http://developers.hubspot.com/docs/methods/lists/get_list}
      def find(id)
        url = Hubspot::Utils.generate_url(LIST_PATH, {list_id: id})
        response = HTTParty.get(url, format: :json)

        response.success? ? new(response.parsed_response) : nil 
      end
    end

    attr_reader :id
    attr_reader :portal_id
    attr_reader :name
    attr_reader :properties

    def initialize(response_hash)
      @id = response_hash['listId']
      @portal_id = response_hash['portalId']
      @name = response_hash['name']
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
  end
end