require 'hubspot/utils'
require 'httparty'

module Hubspot
  class Contact
    GET_CONTACT_BY_EMAIL_PATH = "/contacts/v1/contact/email/:contact_email/profile"
    GET_CONTACT_BY_ID_PATH = "/contacts/v1/contact/vid/:contact_id/profile"
    UPDATE_CONTACT_PATH = "/contacts/v1/contact/vid/:contact_id/profile"

    class << self
      def find_by_email(email)
        url = Hubspot::Utils.generate_url(GET_CONTACT_BY_EMAIL_PATH, {contact_email: email})
        resp = HTTParty.get(url)
        if resp.code == 200
          Hubspot::Contact.new(resp.parsed_response)
        else
          nil
        end
      end

      def find_by_id(vid)
        url = Hubspot::Utils.generate_url(GET_CONTACT_BY_ID_PATH, {contact_id: vid})
        resp = HTTParty.get(url)
        if resp.code == 200
          Hubspot::Contact.new(resp.parsed_response)
        else
          nil
        end
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

    def update!(params)
      params.stringify_keys!
      url = Hubspot::Utils.generate_url(UPDATE_CONTACT_PATH, {contact_id: vid})
      query = {"properties" => Hubspot::Utils.hash_to_properties(params)}
      resp = HTTParty.post(url, body: query.to_json)
      raise(Hubspot::RequestError.new(resp.response)) unless resp.success?
      @properties.merge!(params)
      self
    end
  end
end