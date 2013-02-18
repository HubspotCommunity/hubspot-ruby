require 'spec_helper'

describe Hubspot::Contact do
  let(:example_contact_hash) do
    VCR.use_cassette("example_contact", record: :none) do
      HTTParty.get("https://api.hubapi.com/contacts/v1/contact/email/testingapis@hubspot.com/profile?hapikey=demo").parsed_response
    end
  end

  before{ Hubspot.configure(hapikey: "demo") }

  describe "#initialize" do
    subject{ Hubspot::Contact.new(example_contact_hash) }
    it{ should be_an_instance_of Hubspot::Contact }
    its(["email"]){ should == "testingapis@hubspot.com" }
    its(["firstname"]){ should == "Test" }
    its(["lastname"]){ should == "Contact" }
    its(["phone"]){ should == "555-555-2262" }
    its(:vid){ should == 82325 }
  end

  describe ".find_by_email" do
    before{ VCR.insert_cassette("find_contact_by_email", record: :new_episodes) }
    after{ VCR.eject_cassette }
    subject{ Hubspot::Contact.find_by_email(email) }

    context "when the contact is found" do
      let(:email){ "testingapis@hubspot.com" }
      it{ should be_an_instance_of Hubspot::Contact }
      its(:vid){ should == 82325 }
    end

    context "when the contact cannot be found" do
      let(:email){ "notacontact@test.com" }
      it{ should be_nil }
    end
  end

  describe ".find_by_id" do
    before{ VCR.insert_cassette("find_contact_by_id", record: :new_episodes) }
    after{ VCR.eject_cassette }
    subject{ Hubspot::Contact.find_by_id(vid) }

    context "when the contact is found" do
      let(:vid){ 82325 }
      it{ should be_an_instance_of Hubspot::Contact }
      its(:email){ should == "testingapis@hubspot.com" }
    end

    context "when the contact cannot be found" do
      let(:vid){ 9999999 }
      it{ should be_nil }
    end
  end

  describe "#update!" do
    before{ VCR.insert_cassette("update_contact", record: :new_episodes) }
    after{ VCR.eject_cassette }
    let(:contact){ Hubspot::Contact.new(example_contact_hash) }
    let(:params){ {firstname: "Steve", lastname: "Cunningham"} }
    subject{ contact.update!(params) }

    it{ should be_an_instance_of Hubspot::Contact }
    its(["firstname"]){ should ==  "Steve" }
    its(["lastname"]){ should ==  "Cunningham" }

    context "when the request is not successful" do
      let(:contact){ Hubspot::Contact.new({"vid" => "invalid", "properties" => {}})}
      it "raises an error" do
        expect{ subject }.to raise_error Hubspot::RequestError
      end
    end
  end
end