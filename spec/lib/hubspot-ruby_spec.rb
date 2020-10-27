RSpec.describe HubspotLegacy do
  describe ".configure" do
    it "delegates .configure to HubspotLegacy::Config.configure" do
      options = { hapikey: "demo" }
      allow(HubspotLegacy::Config).to receive(:configure).with(options)

      HubspotLegacy.configure(options)

      expect(HubspotLegacy::Config).to have_received(:configure).with(options)
    end
  end
end
