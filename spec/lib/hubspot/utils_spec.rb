describe Hubspot::Utils do
  describe ".properties_to_hash" do
    let(:properties) do
      {
        "email" => {"value" => "email@address.com"},
        "firstname" => {"value" => "Bob"},
        "lastname" => {"value" => "Smith"}
      }
    end
    subject{ Hubspot::Utils.properties_to_hash(properties) }
    its(["email"]){ should == "email@address.com" }
    its(["firstname"]){ should == "Bob" }
    its(["lastname"]){ should == "Smith" }
  end

  describe ".hash_to_properties" do
    let(:hash) do
      {
        "email" => "email@address.com",
        "firstname" => "Bob",
        "lastname" => "Smith"
      }
    end
    subject{ Hubspot::Utils.hash_to_properties(hash) }
    it{ should be_an_instance_of Array }
    its(:length){ should == 3 }
    it{ should include({"property" => "email", "value" => "email@address.com"}) }
    it{ should include({"property" => "firstname", "value" => "Bob"}) }
    it{ should include({"property" => "lastname", "value" => "Smith"}) }
  end

  describe ".generate_url" do
    let(:path){ "/test/:email/profile" }
    let(:params){{email: "test"}}
    let(:options){{}}
    subject{ Hubspot::Utils.generate_url(path, params, options) }
    before{ Hubspot.configure(hapikey: "demo", portal_id: "62515") }

    it "doesn't modify params" do
      expect{ subject }.to_not change{params}
    end

    context "with a portal_id param" do
      let(:path){ "/test/:portal_id/profile" }
      let(:params){{}}
      it{ should == "https://api.hubapi.com/test/62515/profile?hapikey=demo" }
    end

    context "when configure hasn't been called" do
      before{ Hubspot::Config.reset! }
      it "raises a config exception" do
        expect{ subject }.to raise_error Hubspot::ConfigurationError
      end
    end

    context "with interpolations but no params" do
      let(:params){{}}
      it "raises an interpolation exception" do
        expect{ subject }.to raise_error Hubspot::MissingInterpolation
      end
    end

    context "with an interpolated param" do
      let(:params){ {email: "email@address.com"} }
      it{ should == "https://api.hubapi.com/test/email@address.com/profile?hapikey=demo" }
    end

    context "with multiple interpolated params" do
      let(:path){ "/test/:email/:id/profile" }
      let(:params){{email: "email@address.com", id: 1234}}
      it{ should == "https://api.hubapi.com/test/email@address.com/1234/profile?hapikey=demo" }
    end

    context "with query params" do
      let(:params){{email: "email@address.com", id: 1234}}
      it{ should == "https://api.hubapi.com/test/email@address.com/profile?id=1234&hapikey=demo" }

      context "containing a time" do
        let(:start_time) { Time.now }
        let(:params){{email: "email@address.com", id: 1234, start: start_time}}
        it{ should == "https://api.hubapi.com/test/email@address.com/profile?id=1234&start=#{start_time.to_i * 1000}&hapikey=demo" }
      end

      context "containing a range" do
        let(:start_time) { Time.now }
        let(:end_time) { Time.now + 1.year }
        let(:params){{email: "email@address.com", id: 1234, created__range: start_time..end_time }}
        it{ should == "https://api.hubapi.com/test/email@address.com/profile?id=1234&created__range=#{start_time.to_i * 1000}&created__range=#{end_time.to_i * 1000}&hapikey=demo" }
      end
    end

    context "with options" do

      let(:options){ {base_url: "https://cool.com", hapikey: false} }
      it{ should == "https://cool.com/test/test/profile"}
    end

    context "passing Array as parameters for batch mode, key is prefixed with batch_" do 
      let(:path) { Hubspot::ContactList::LIST_BATCH_PATH }
      let(:params) { { batch_list_id: [1,2,3] } }
      it{ should == "https://api.hubapi.com/contacts/v1/lists/batch?listId=1&listId=2&listId=3&hapikey=demo" }
    end
  end
end
