require 'spec_helper'

describe Hubspot do
  describe "#configure" do
    it "delegates a call to Hubspot::Config.configure" do
      mock(Hubspot::Config).configure({hapikey: "demo"})
      Hubspot.configure hapikey: "demo"
    end
  end
end
