describe "Companies API Live test", live: true do
  # Let's try to hit all the API endpoints at least once

  before do
    Hubspot.configure hapikey: "demo"
  end

  it 'find, update, batch_update and destroy a company' do
    companies = Hubspot::Company.find_by_domain("create-delete-test.com")
    companies.first.destroy! if companies.any?

    company = Hubspot::Company.create!("Create Delete Test", domain: "create-delete-test.com")
    expect(company).to be_present

    company.update! name: "Create Delete Test 2"
    company = Hubspot::Company.find_by_id(company.vid)


    expect(company["name"]).to eql "Create Delete Test 2"

    Hubspot::Company.batch_update!([{objectId: company.vid, name: 'Batch Update'}])
    sleep 0.5 # prevent bulk update hasn't finished propagation
    company = Hubspot::Company.find_by_id(company.vid)

    expect(company["name"]).to eql "Batch Update"

    expect(company.destroy!).to be_true
    expect(Hubspot::Company.find_by_domain("create-delete-test.com")).to eq []

  end
end
