require 'spec_helper'

describe "Contacts API Live test", live: true do
  # Let's try to hit all the API endpoints at least once

  before do
    Hubspot.configure hapikey: "demo"
  end

  it 'find, update and destroy a contact' do
    contact = Hubspot::Contact.find_by_email("create_delete_test@hsgemtest.com")
    contact.destroy! if contact

    contact = Hubspot::Contact.create!("create_delete_test@hsgemtest.com")
    expect(contact).to be_present

    contact.update! firstname: "Clint", lastname: "Eastwood"
    contact = Hubspot::Contact.find_by_id(contact.vid)

    expect(contact["firstname"]).to eql "Clint"
    expect(contact["lastname"]).to eql "Eastwood"

    expect(contact.destroy!).to be_true
    expect(Hubspot::Contact.find_by_email("create_delete_test@hsgemtest.com")).to be_nil
  end
end