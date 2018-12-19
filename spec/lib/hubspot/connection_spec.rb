describe Hubspot::Connection do
  before do
    Hubspot.configure hapikey: 'fake'
  end

  describe ".get_json" do
    it "returns the parsed response from the GET request" do
      path = "/some/path"
      body = { key: "value" }

      stub_request(:get, "https://api.hubapi.com/some/path?hapikey=fake").
        to_return(status: 200, body: JSON.generate(body))

      result = Hubspot::Connection.get_json(path, {})

      expect(result).to eq({ "key" => "value" })
    end
  end

  describe ".post_json" do
    it "returns the parsed response from the POST request" do
      path = "/some/path"
      body = { id: 1, name: "ABC" }

      stub_request(:post, "https://api.hubapi.com/some/path?hapikey=fake&name=ABC").
        to_return(status: 200, body: JSON.generate(body))

      result = Hubspot::Connection.post_json(path, params: { name: "ABC" })

      expect(result).to eq({ "id" => 1, "name" => "ABC" })
    end
  end

  describe ".delete_json" do
    it "returns the response from the DELETE request" do
      path = "/some/path"

      stub_request(:delete, "https://api.hubapi.com/some/path?hapikey=fake").
        to_return(status: 204, body: JSON.generate({}))

      result = Hubspot::Connection.delete_json(path, {})

      expect(result.code).to eq(204)
    end
  end

  describe ".put_json" do
    it "issues a PUT request and returns the parsed body" do
      path = "/some/path"
      update_options = { params: {}, body: {} }

      stub_request(:put, "https://api.hubapi.com/some/path?hapikey=fake").
        to_return(status: 200, body: JSON.generate(vid: 123))

      response = Hubspot::Connection.put_json(path, update_options)

      assert_requested(
        :put,
        "https://api.hubapi.com/some/path?hapikey=fake",
         {
           body: "{}",
           headers: { "Content-Type" => "application/json" },
         }
      )

      expect(response).to eq({ "vid" => 123 })
    end

    it "logs information about the request and response" do
      path = "/some/path"
      update_options = { params: {}, body: {} }

      logger = stub_logger

      stub_request(:put, "https://api.hubapi.com/some/path?hapikey=fake").
        to_return(status: 200, body: JSON.generate("response body"))

      Hubspot::Connection.put_json(path, update_options)

      expect(logger).to have_received(:info).with(<<~MSG)
        Hubspot: https://api.hubapi.com/some/path?hapikey=fake.
        Body: {}.
        Response: 200 "response body"
      MSG
    end

    it "raises when the request fails" do
      path = "/some/path"
      update_options = { params: {}, body: {} }

      stub_request(:put, "https://api.hubapi.com/some/path?hapikey=fake").
        to_return(status: 401)

      expect {
        Hubspot::Connection.put_json(path, update_options)
      }.to raise_error(Hubspot::RequestError)
    end
  end

  context 'private methods' do
    describe ".generate_url" do
      let(:path){ "/test/:email/profile" }
      let(:params){{email: "test"}}
      let(:options){{}}
      subject{ Hubspot::Connection.send(:generate_url, path, params, options) }
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
        it{ should == "https://api.hubapi.com/test/email%40address.com/profile?hapikey=demo" }
      end

      context "with multiple interpolated params" do
        let(:path){ "/test/:email/:id/profile" }
        let(:params){{email: "email@address.com", id: 1234}}
        it{ should == "https://api.hubapi.com/test/email%40address.com/1234/profile?hapikey=demo" }
      end

      context "with query params" do
        let(:params){{email: "email@address.com", id: 1234}}
        it{ should == "https://api.hubapi.com/test/email%40address.com/profile?id=1234&hapikey=demo" }

        context "containing a time" do
          let(:start_time) { Time.now }
          let(:params){{email: "email@address.com", id: 1234, start: start_time}}
          it{ should == "https://api.hubapi.com/test/email%40address.com/profile?id=1234&start=#{start_time.to_i * 1000}&hapikey=demo" }
        end

        context "containing a range" do
          let(:start_time) { Time.now }
          let(:end_time) { Time.now + 1.year }
          let(:params){{email: "email@address.com", id: 1234, created__range: start_time..end_time }}
          it{ should == "https://api.hubapi.com/test/email%40address.com/profile?id=1234&created__range=#{start_time.to_i * 1000}&created__range=#{end_time.to_i * 1000}&hapikey=demo" }
        end

        context "containing an array of strings" do
          let(:path){ "/test/emails" }
          let(:params){{batch_email: %w(email1@example.com email2@example.com)}}
          it{ should == "https://api.hubapi.com/test/emails?email=email1%40example.com&email=email2%40example.com&hapikey=demo" }
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

  def stub_logger
    instance_double(Logger, info: true).tap do |logger|
      allow(Hubspot::Config).to receive(:logger).and_return(logger)
    end
  end
end
