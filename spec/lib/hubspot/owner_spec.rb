describe HubSpot::Owner do
  let(:example_owners) do
    VCR.use_cassette('owner_example') do
      HTTParty.get('https://api.hubapi.com/owners/v2/owners?hapikey=demo&portalId=62515').parsed_response
    end
  end

  before { HubSpot.configure(hapikey: 'demo') }

  describe '.all' do
    cassette 'owner_all'

    it 'should find all owners' do
      owners = HubSpot::Owner.all

      expect(owners.blank?).to be_false
      compare_owners(owners, example_owners)
    end
  end

  describe '.find_by_email' do
    cassette 'owner_find_by_email'

    let(:sample) { example_owners.first }
    let(:email) { sample['email'] }

    it 'should find a user via their email address' do
      owner = HubSpot::Owner.find_by_email(email)
      sample.map do |key, val|
        expect(owner[key]).to eq(val)
      end
    end
  end

  describe '.find_by_emails' do
    cassette 'owner_find_by_emails'

    let(:samples) { example_owners[0..[example_owners.count, 3].min] }
    let(:emails) { samples.map { |s| s['email'] } }

    it 'should find users via their email address' do
      owners = HubSpot::Owner.find_by_emails(emails)
      compare_owners(owners, samples)
    end
  end
end

def compare_owners(owners, examples)
  owners.each do |owner|
    example = examples.detect { |o| o['email'] == owner.email }
    expect(example.blank?).to be_false
    example.each do |key, val|
      expect(owner[key]).to eq(val)
    end
  end
end
