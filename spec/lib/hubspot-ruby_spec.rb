RSpec.describe Hubspot do
  describe ".configure" do
    it "delegates .configure to Hubspot::Config.configure" do
      options = { hapikey: "demo" }
      allow(Hubspot::Config).to receive(:configure).with(options)

      Hubspot.configure(options)

      expect(Hubspot::Config).to have_received(:configure).with(options)
    end
  end
end
