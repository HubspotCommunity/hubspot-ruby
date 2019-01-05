module Hubspot
  class Contact2 < Hubspot::Resource
    self.id_field = "vid"
    self.update_method = "post"

    CREATE_PATH             = '/contacts/v1/contact'
    DELETE_PATH             = '/contacts/v1/contact/vid/:id'
    FIND_PATH               = '/contacts/v1/contact/vid/:id/profile'
    FIND_BY_EMAIL_PATH      = '/contacts/v1/contact/email/:email/profile'
    FIND_BY_USER_TOKEN_PATH = '/contacts/v1/contact/utk/:token/profile'
    UPDATE_PATH             = '/contacts/v1/contact/vid/:id/profile'

    class << self
      def find_by_email(email)
        response = Hubspot::Connection.get_json(FIND_BY_EMAIL_PATH, email: email)
        new(response["vid"], response)
      end

      def find_by_user_token(token)
        response = Hubspot::Connection.get_json(FIND_BY_USER_TOKEN_PATH, token: token)
        new(response["vid"], response)
      end
      alias_method :find_by_utk, :find_by_user_token

      def create(email, properties = {})
        super(properties.merge("email" => email))
      end
    end

    def name
      [firstname, lastname].compact.join(' ')
    end
  end
end