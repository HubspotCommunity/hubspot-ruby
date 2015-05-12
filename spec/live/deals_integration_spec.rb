describe "Deals API Live test", live: true do

  before do
    Hubspot.configure hapikey: "demo"
  end

  it 'create.....' do
    contact = Hubspot::Contact.find_by_email("create_delete_test@hsgemtest.com")
    contact ||= Hubspot::Contact.create!("create_delete_test@hsgemtest.com")

    expect(contact).to be_present

    deal = Hubspot::Deal.create!(62515, [], [contact.vid], { amount: 30, dealstage: 'closedwon' })
    expect(deal).to be_present

    expect(deal['dealstage']).to eql 'closedwon'

    deal.update!({dealstage: 'closedlost'})

    expect(deal['dealstage']).to eql 'closedlost'

    #to be sure it was updates
    updated_deal = Hubspot::Deal.find(deal.deal_id)
  end


  # it 'find, update and destroy a contact' do
  #   contact = Hubspot::Contact.find_by_email("create_delete_test@hsgemtest.com")
  #   contact.destroy! if contact

  #   contact = Hubspot::Contact.create!("create_delete_test@hsgemtest.com")
  #   expect(contact).to be_present

  #   contact.update! firstname: "Clint", lastname: "Eastwood"
  #   contact = Hubspot::Contact.find_by_id(contact.vid)

  #   expect(contact["firstname"]).to eql "Clint"
  #   expect(contact["lastname"]).to eql "Eastwood"

  #   expect(contact.destroy!).to be_true
  #   expect(Hubspot::Contact.find_by_email("create_delete_test@hsgemtest.com")).to be_nil
  # end
end