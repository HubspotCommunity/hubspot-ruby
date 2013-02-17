require 'spec_helper'

describe Hubspot::Utils do
  describe ".parse_properties" do
    let(:properties) do
      {
        "email" => {"value" => "email@address.com"},
        "firstname" => {"value" => "Bob"},
        "lastname" => {"value" => "Smith"}
      }
    end
    subject{ Hubspot::Utils.parse_properties(properties) }
    its(["email"]){ should == "email@address.com" }
    its(["firstname"]){ should == "Bob" }
    its(["lastname"]){ should == "Smith" }
  end

  describe ".generate_url" do
    let(:path){ "/test/:email/profile" }
    let(:params){{}}
    subject{ Hubspot::Utils.generate_url(path, params) }
    before{ Hubspot.configure(hapikey: "demo") }

    context "when configure hasn't been called" do
      before{ Hubspot::Config.reset! }
      it "raises a config exception" do
        expect{ subject }.to raise_error Hubspot::ConfigurationError
      end
    end

    context "with interpolations but no params" do
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
    end
  end
end
