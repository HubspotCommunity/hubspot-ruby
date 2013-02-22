module Hubspot
  class RequestError < StandardError
    def initialize(response, message=nil)
      message += "\n" if message
      super("#{message}Response body: #{response.body}")
    end
  end

  class ConfigurationError < StandardError; end
  class MissingInterpolation < StandardError; end
  class ContactExistsError < RequestError; end
end