describe Hubspot::Contact do
  let(:example_company_hash) do
    VCR.use_cassette("company_example", record: :none) do
      HTTParty.get("https://api.hubapi.com/companies/v2/companies/21827084?hapikey=demo").parsed_response
    end
  end
  let(:company_with_contacts_hash) do
    VCR.use_cassette("company_with_contacts", record: :none) do
      HTTParty.get("https://api.hubapi.com/companies/v2/companies/115200636?hapikey=demo").parsed_response
    end
  end

  before{ Hubspot.configure(hapikey: "demo") }

  describe "#initialize" do
    subject{ Hubspot::Company.new(example_company_hash) }
    it{ should be_an_instance_of Hubspot::Company }
    its(["name"]){ should == "HubSpot" }
    its(["domain"]){ should == "hubspot.com" }
    its(:vid){ should == 21827084 }
  end

  describe ".create!" do
    cassette "company_create"
    let(:params){{}}
    subject{ Hubspot::Company.create!(name, params) }
    context "with a new name" do
      let(:name){ "New Company #{Time.now.to_i}" }
      it{ should be_an_instance_of Hubspot::Company }
      its(:name){ should match /New Company .*/ } # Due to VCR the email may not match exactly

      context "and some params" do
        cassette "company_create_with_params"
        let(:name){ "New Company with Params #{Time.now.to_i}" }
        let(:params){ {domain: "new-company-domain-#{Time.now.to_i}"} }
        its(["name"]){ should match /New Company with Params/ }
        its(["domain"]){ should match /new\-company\-domain/ }
      end
    end
  end

  describe ".add_contact!" do
    cassette "add_contact_to_company_class"
    let(:company){ Hubspot::Company.create!("company_#{Time.now.to_i}@example.com") }
    let(:contact){ Hubspot::Contact.create!("contact_#{Time.now.to_i}@example.com") }
    subject { Hubspot::Company.find_by_id(company.vid) }

    before { Hubspot::Company.add_contact! company.vid, contact.vid }
    its(['num_associated_contacts']) { should eql '1' }
  end

  describe ".find_by_id" do
    context 'given an uniq id' do
      cassette "company_find_by_id"
      subject{ Hubspot::Company.find_by_id(vid) }

      context "when the company is found" do
        let(:vid){ 21827084 }
        it{ should be_an_instance_of Hubspot::Company }
        its(:name){ should == "HubSpot" }
      end

      context "when the contact cannot be found" do
        it 'raises an error' do
          expect { Hubspot::Company.find_by_id(9999999) }.to raise_error(Hubspot::RequestError)
        end
      end
    end
  end


  describe ".find_by_domain" do
    context 'given a domain' do
      cassette "company_find_by_domain"
      subject(:companies) { Hubspot::Company.find_by_domain("example.com") }

      context "when a company is found" do
        it { should be_an_instance_of Array }
        it { should_not be_empty }

        it 'must contain all available properties' do
          companies[0..9].each do |company|
            expect(company.properties).to eql Hubspot::Company.find_by_id(company.vid).properties
          end
        end
      end

      context "when a company cannot be found" do
        subject { Hubspot::Company.find_by_domain("asdf1234baddomain.com") }
        it { should be_an_instance_of Array }
        it { should be_empty }
      end
    end

    context 'given a domain and parameters' do
      cassette 'company_find_by_domain_with_params'
      subject(:companies) { Hubspot::Company.find_by_domain("example.com", limit: 2, properties: ["name", "createdate"], offset_company_id: 117004411) }

      context "when a company is found" do
        it{ should be_an_instance_of Array }
        it{ should_not be_empty }

        it 'must use the parameters to search' do
          expect(companies.size).to eql 2
          expect(companies.first['name']).to be_a_kind_of String
          expect(companies.first['createdate']).to be_a_kind_of String
          expect(companies.first['domain']).to be_nil
          expect(companies.first['hs_lastmodifieddate']).to be_nil
        end
      end
    end
  end

  describe '.all' do
    context 'all companies' do
      cassette 'find_all_companies'

      it 'must get the companies list' do
        companies = Hubspot::Company.all

        expect(companies.size).to eql 20 # default page size

        first = companies.first
        last = companies.last

        expect(first).to be_a Hubspot::Company
        expect(first.vid).to eql 42866817
        expect(first['name']).to eql 'name'

        expect(last).to be_a Hubspot::Company
        expect(last.vid).to eql 42861017
        expect(last['name']).to eql 'Xge5rbdt2zm'
      end

      it 'must filter only 2 companies' do
        copmanies = Hubspot::Company.all(count: 2)
        expect(copmanies.size).to eql 2
      end

      context 'all_with_offset' do
        it 'should return companies with offset and hasMore' do
          response = Hubspot::Company.all_with_offset
          expect(response['results'].size).to eq(20)

          first = response['results'].first
          last = response['results'].last

          expect(first).to be_a Hubspot::Company
          expect(first.vid).to eq(42866817)
          expect(first['name']).to eql 'name'
          expect(last).to be_a Hubspot::Company
          expect(last.vid).to eql 42861017
          expect(last['name']).to eql 'Xge5rbdt2zm'
        end

        it 'must filter only 2 companies' do
          response = Hubspot::Company.all_with_offset(count: 2)
          expect(response['results'].size).to eq(2)
          expect(response['hasMore']).to be_truthy
          expect(response['offset']).to eq(2)
        end
      end
    end

    context 'recent companies' do
      cassette 'find_all_recent_companies'

      it 'must get the companies list' do
        companies = Hubspot::Company.all(recently_updated: true)
        expect(companies.size).to eql 20

        first, last = companies.first, companies.last
        expect(first).to be_a Hubspot::Company
        expect(first.vid).to eql 318615742

        expect(last).to be_a Hubspot::Company
        expect(last.vid).to eql 359899290
      end
    end
  end

  describe "#update!" do
    cassette "company_update"
    let(:company){ Hubspot::Company.new(example_company_hash) }
    let(:params){ {name: "Acme Cogs", domain: "abccogs.com"} }
    subject{ company.update!(params) }

    it{ should be_an_instance_of Hubspot::Company }
    its(["name"]){ should ==  "Acme Cogs" }
    its(["domain"]){ should ==  "abccogs.com" }

    context "when the request is not successful" do
      let(:company){ Hubspot::Company.new({"vid" => "invalid", "properties" => {}})}
      it "raises an error" do
        expect{ subject }.to raise_error Hubspot::RequestError
      end
    end
  end

  describe "#batch_update!" do
    cassette "company_batch_update"
    let(:company){ Hubspot::Company.create!("company_#{Time.now.to_i}@example.com") }

    context 'update via vid' do
      let(:updated_companies) { [{ vid: company.vid, name: "Carol H" }] }

      it 'should update companies' do
        Hubspot::Company.batch_update!(updated_companies)
        checked_company = Hubspot::Company.find_by_id(company.vid)
        expect(checked_company.properties["name"]).to eq("Carol H")
      end
    end

    context 'update via objectId' do
      let(:updated_companies) { [{ objectId: company.vid, name: "Carol H" }] }

      it 'should update companies' do
        Hubspot::Company.batch_update!(updated_companies)
        checked_company = Hubspot::Company.find_by_id(company.vid)
        expect(checked_company.properties["name"]).to eq("Carol H")
      end
    end

    context 'missing vid or objectId' do
      let(:updated_companies) { [{ name: "Carol H" }] }

      it 'should raise error with expected message' do
        expect { Hubspot::Company.batch_update!(updated_companies) }.to raise_error(Hubspot::InvalidParams, 'expecting vid or objectId for company')
      end
    end
  end

  describe "#destroy!" do
    cassette "company_destroy"
    let(:company){ Hubspot::Company.create!("newcompany_y_#{Time.now.to_i}@hsgem.com") }
    subject{ company.destroy! }
    it { should be_true }
    it "should be destroyed" do
      subject
      company.destroyed?.should be_true
    end
    context "when the request is not successful" do
      let(:company){ Hubspot::Company.new({"vid" => "invalid", "properties" => {}})}
      it "raises an error" do
        expect{ subject }.to raise_error Hubspot::RequestError
        company.destroyed?.should be_false
      end
    end
  end

  describe "#get_contact_vids" do
    cassette "company_get_contact_vids"
    let(:company) { Hubspot::Company.create!("company_#{Time.now.to_i}@example.com") }
    let(:contact) { Hubspot::Contact.create!("contact_#{Time.now.to_i}@example.com") }
    before { company.add_contact(contact) }
    subject { company.get_contact_vids }

    it { is_expected.to eq [contact.vid] }
  end

  describe "#add_contact" do
    cassette "add_contact_to_company_instance"
    let(:company){ Hubspot::Company.create!("company_#{Time.now.to_i}@example.com") }
    let(:contact){ Hubspot::Contact.create!("contact_#{Time.now.to_i}@example.com") }
    subject { Hubspot::Company.find_by_id(company.vid) }

    context "with Hubspot::Contact instance" do
      before { company.add_contact contact }
      its(['num_associated_contacts']) { should eql '1' }
    end

    context "with vid" do
      before { company.add_contact contact.vid }
      its(['num_associated_contacts']) { should eql '1' }
    end
  end

  describe "#destroyed?" do
    let(:company){ Hubspot::Company.new(example_company_hash) }
    subject{ company }
    its(:destroyed?){ should be_false }
  end

  describe "#contacts" do
    let(:company){ Hubspot::Company.new(company_with_contacts_hash) }
    subject do
      VCR.use_cassette("company_contacts") { company.contacts }
    end

    its(:size) { should eql 5 }
  end
end
