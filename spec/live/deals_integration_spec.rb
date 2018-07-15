describe "Deals API Live test", live: true do

  before do
    HubSpot.configure hapikey: "demo"
  end

  it 'should create, find, update and destroy' do
    contact = HubSpot::Contact.find_by_email("create_delete_test@hsgemtest.com") rescue nil
    contact ||= HubSpot::Contact.create!("create_delete_test@hsgemtest.com")

    expect(contact).to be_present

    deal = HubSpot::Deal.create!(62515, [], [contact.vid], { amount: 30, dealstage: 'closedwon' })
    expect(deal).to be_present

    expect(deal['dealstage']).to eql 'closedwon'

    deal.update!({dealstage: 'closedlost'})

    expect(deal['dealstage']).to eql 'closedlost'
    expect(deal['amount']).to eql '30'

    #to be sure it was updated
    updated_deal = HubSpot::Deal.find(deal.deal_id)

    expect(updated_deal['dealstage']).to eql 'closedlost'
    expect(updated_deal['amount']).to eql '30'

    expect(deal.destroy!).to be true
    expect(contact.destroy!).to be true

    # cant find anymore
    expect { HubSpot::Deal.find(deal.deal_id) }.to raise_error
  end
end
