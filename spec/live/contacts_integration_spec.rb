require 'spec_helper'

describe "Contacts API Live test", live: true do
  # Let's try to hit all the API endpoints at least once

  before do
    Hubspot.configure hapikey: "demo"
  end

  it "finds and updates a contact" do
    contact = Hubspot::Contact.find_by_email "testingapis@hubspot.com"
    contact.update! firstname: "Clint", lastname: "Eastwood"
    contact = Hubspot::Contact.find_by_id contact.vid
    contact["firstname"].should == "Clint"
    contact["lastname"].should == "Eastwood"
  end

  it "creates and destroys a contact" do
    contact = Hubspot::Contact.find_by_email("create_delete_test@hsgemtest.com")
    contact.destroy! if contact
    Hubspot::Contact.create!("create_delete_test@hsgemtest.com")
    contact = Hubspot::Contact.find_by_email("create_delete_test@hsgemtest.com")
    contact.should be_present
    contact.destroy!
    contact = Hubspot::Contact.find_by_email("create_delete_test@hsgemtest.com")
    contact.should_not be_present
  end

  it "finds a contact by utk" do
    Hubspot::Contact.find_by_utk("f844d2217850188692f2610c717c2e9b").should be_present
  end
end