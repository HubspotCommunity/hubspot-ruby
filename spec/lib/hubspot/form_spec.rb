require 'spec_helper'

describe Hubspot::Form do
  describe "#url" do
    let(:form_guid){ "abcd-efgh-1234-5678" }
    subject{ Hubspot::Form.new(form_guid) }

    context "when a portal_id is configured" do
      before { Hubspot.configure hapikey: "demo", portal_id: "62515" }
      its(:url){ should == "https://forms.hubspot.com/uploads/form/v2/62515/abcd-efgh-1234-5678" }
    end

    context "when a portal_id is not configured" do
      before { Hubspot.configure hapikey: "demo" }
      it "raises an exception" do
        expect{ subject.url }.to raise_error Hubspot::ConfigurationError
      end
    end
  end
end