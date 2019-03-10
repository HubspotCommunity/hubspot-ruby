class Hubspot::Contact2 < Hubspot::Resource
  self.id_field = "vid"
  self.update_method = "post"

  CREATE_PATH             = '/contacts/v1/contact'
  CREATE_OR_UPDATE_PATH   = '/contacts/v1/contact/createOrUpdate/email/:email'
  DELETE_PATH             = '/contacts/v1/contact/vid/:id'
  FIND_PATH               = '/contacts/v1/contact/vid/:id/profile'
  FIND_BY_EMAIL_PATH      = '/contacts/v1/contact/email/:email/profile'
  FIND_BY_USER_TOKEN_PATH = '/contacts/v1/contact/utk/:token/profile'
  UPDATE_PATH             = '/contacts/v1/contact/vid/:id/profile'

  class << self
    def find_by_email(email)
      response = Hubspot::Connection.get_json(FIND_BY_EMAIL_PATH, email: email)
      from_result(response)
    end

    def find_by_user_token(token)
      response = Hubspot::Connection.get_json(FIND_BY_USER_TOKEN_PATH, token: token)
      from_result(response)
    end
    alias_method :find_by_utk, :find_by_user_token

    def create(email, properties = {})
      super(properties.merge("email" => email))
    end

    def create_or_update(email, properties = {})
      request = {
        properties: Hubspot::Utils.hash_to_properties(properties.stringify_keys, key_name: "property")
      }
      response = Hubspot::Connection.post_json(CREATE_OR_UPDATE_PATH, params: {email: email}, body: request)
      from_result(response)
    end
  end

  def name
    [firstname, lastname].compact.join(' ')
  end
end
