describe "Companies API Live test", live: true do
  # Let's try to hit all the API endpoints at least once

  before do
    Hubspot.configure hapikey: "demo"
  end

  it 'find, update and destroy a company' do
    companies = Hubspot::Company.find_by_domain("create-delete-test.com")
    companies.first.destroy! if companies.any?

    company = Hubspot::Company.create!("Create Delete Test", domain: "create-delete-test.com")
    expect(company).to be_present

    company.update! name: "Create Delete Test 2"
    company = Hubspot::Company.find_by_id(company.vid)

    expect(company["name"]).to eql "Create Delete Test 2"

    expect(company.destroy!).to be_true
    expect(Hubspot::Company.find_by_domain("create-delete-test.com")).to eq []
  end
end