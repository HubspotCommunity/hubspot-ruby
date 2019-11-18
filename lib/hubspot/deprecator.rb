module Hubspot
  class Deprecator
    def self.build(version: "1.0")
      ActiveSupport::Deprecation.new(version, "hubspot-api-ruby")
    end
  end
end
