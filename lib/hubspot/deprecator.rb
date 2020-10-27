module HubspotLegacy
  class Deprecator
    def self.build(version: "1.0")
      ActiveSupport::Deprecation.new(version, "hubspot-api-legacy")
    end
  end
end
