describe HubSpot do
  describe "#configure" do
    it "delegates a call to HubSpot::Config.configure" do
      mock(HubSpot::Config).configure({hapikey: "demo"})
      HubSpot.configure hapikey: "demo"
    end
  end
end
