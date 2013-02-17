require 'hubspot/utils'
require 'httparty'

module Hubspot
  class Contact
    GET_CONTACT_BY_EMAIL_URL = "/contacts/v1/contact/email/:contact_email/profile"

    class << self
      def find_by_email(email)
        url = Hubspot::Utils.generate_url(GET_CONTACT_BY_EMAIL_URL, {contact_email: email})
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
      @properties = Hubspot::Utils.parse_properties(response_hash["properties"])
      @vid = response_hash["vid"]
    end

    def [](property)
      @properties[property]
    end

    def email
      @properties["email"]
    end
  end
end