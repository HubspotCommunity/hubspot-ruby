require 'spec_helper'

describe Hubspot::Config do
  describe "#configure" do
    let(:config){ {hapikey: "demo", base_url: "http://api.hubapi.com/v2"} }
    subject{ Hubspot::Config.configure(config) }

    it "changes the hapikey config" do
      expect{ subject }.to change(Hubspot::Config, :hapikey).to("demo")
    end

    it "changes the base_url" do
      expect{ subject }.to change(Hubspot::Config, :base_url).to("http://api.hubapi.com/v2")
    end

    it "sets a default value for base_url" do
      Hubspot::Config.base_url.should == "https://api.hubapi.com"
    end
  end
end