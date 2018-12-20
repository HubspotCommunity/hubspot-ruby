module Hubspot
  class Response
    attr_reader :body

    def initialize(body:)
      @body = body
    end
  end
end
