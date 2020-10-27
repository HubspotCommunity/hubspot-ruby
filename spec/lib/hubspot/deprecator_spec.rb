RSpec.describe HubspotLegacy::Deprecator do
  describe ".build" do
    it "returns an instance of ActiveSupport::Deprecation" do
      deprecator = HubspotLegacy::Deprecator.build

      expect(deprecator).to be_an_instance_of(ActiveSupport::Deprecation)
    end

    it "uses the correct gem name" do
      deprecator = HubspotLegacy::Deprecator.build

      expect(deprecator.gem_name).to eq("hubspot-api-legacy")
    end
  end
end
