describe HubspotLegacy::Engagement do
  let(:example_engagement_hash) do
    VCR.use_cassette("engagement_example") do
      HTTParty.get("https://api.hubapi.com/engagements/v1/engagements/51484873?hapikey=demo").parsed_response
    end
  end
  let(:example_associated_engagement_hash) do
    VCR.use_cassette("engagement_associated_example") do
      HTTParty.get("https://api.hubapi.com/engagements/v1/engagements/58699206?hapikey=demo").parsed_response
    end
  end

  # http://developers.hubspot.com/docs/methods/contacts/get_contact
  before{ HubspotLegacy.configure(hapikey: "demo") }

  describe "#initialize" do
    subject{ HubspotLegacy::Engagement.new(example_engagement_hash) }
    it  { should be_an_instance_of HubspotLegacy::Engagement }
    its (:id) { should == 51484873 }
  end

  describe 'EngagementNote' do
    describe ".create!" do
      cassette "engagement_create"
      body = "Test note"
      subject { HubspotLegacy::EngagementNote.create!(nil, body) }
      its(:id) { should_not be_nil }
      its(:body) { should eql body }
    end

    describe ".find" do
      cassette "engagement_find"
      let(:engagement) {HubspotLegacy::EngagementNote.new(example_engagement_hash)}

      it 'must find by the engagement id' do
        find_engagement = HubspotLegacy::EngagementNote.find(engagement.id)
        find_engagement.id.should eql engagement.id
        find_engagement.body.should eql engagement.body
      end
    end

    describe ".find_by_company" do
      cassette "engagement_find_by_country"
      let(:engagement) {HubspotLegacy::EngagementNote.new(example_associated_engagement_hash)}

      it 'must find by company id' do
        find_engagements = HubspotLegacy::EngagementNote.find_by_company(engagement.associations["companyIds"].first)
        find_engagements.should_not be_nil
        find_engagements.any?{|engagement| engagement.id == engagement.id and engagement.body == engagement.body}.should be true
      end
    end

    describe ".find_by_contact" do
      cassette "engagement_find_by_contact"
      let(:engagement) {HubspotLegacy::EngagementNote.new(example_associated_engagement_hash)}

      it 'must find by contact id' do
        find_engagements = HubspotLegacy::EngagementNote.find_by_contact(engagement.associations["contactIds"].first)
        find_engagements.should_not be_nil
        find_engagements.any?{|engagement| engagement.id == engagement.id and engagement.body == engagement.body}.should be true
      end
    end

    describe ".find_by_association" do
      cassette "engagement_find_by_association"

      it 'must raise for fake association type' do
        expect {
          HubspotLegacy::EngagementNote.find_by_association(1, 'FAKE_TYPE')
        }.to raise_error
      end
    end

    describe ".associate!" do
      cassette "engagement_associate"

      let(:engagement) { HubspotLegacy::EngagementNote.create!(nil, 'note') }
      let(:contact) { HubspotLegacy::Contact.create(email: "newcontact#{Time.now.to_i}@hsgem.com") }
      subject { HubspotLegacy::Engagement.associate!(engagement.id, 'contact', contact.id) }

      it 'associate an engagement to a resource' do
        subject
        found_by_contact = HubspotLegacy::Engagement.find_by_contact(contact.id)
        expect(found_by_contact.first.id).to eql engagement.id
      end
    end

    describe '#destroy!' do
      cassette 'engagement_destroy'

      let(:engagement) {HubspotLegacy::EngagementNote.create!(nil, 'test note') }

      it 'should remove from hubspot' do
        expect(HubspotLegacy::Engagement.find(engagement.id)).to_not be_nil

        expect(engagement.destroy!).to be true
        expect(engagement.destroyed?).to be true

        expect(HubspotLegacy::Engagement.find(engagement.id)).to be_nil
      end
    end
  end

  describe 'EngagementCall' do
    let(:example_engagement_hash) do
      VCR.use_cassette("engagement_call_example") do
        HTTParty.get("https://api.hubapi.com/engagements/v1/engagements/4709059?hapikey=demo").parsed_response
      end
    end

    describe ".create!" do
      cassette "engagement_call_create"
      body = "Test call"
      subject { HubspotLegacy::EngagementCall.create!(nil, body, 0) }
      its(:id) { should_not be_nil }
      its(:body) { should eql body }
    end

    describe ".find" do
      cassette "engagement_call_find"
      let(:engagement) { HubspotLegacy::EngagementNote.new(example_engagement_hash) }

      it 'must find by the engagement id' do
        find_engagement = HubspotLegacy::EngagementNote.find(engagement.id)
        find_engagement.id.should eql engagement.id
        find_engagement.body.should eql engagement.body
      end
    end

    describe '#destroy!' do
      cassette 'engagement_call_destroy'

      let(:engagement) { HubspotLegacy::EngagementCall.create!(nil, 'test call', 0) }

      it 'should remove from hubspot' do
        expect(HubspotLegacy::Engagement.find(engagement.id)).to_not be_nil

        expect(engagement.destroy!).to be true
        expect(engagement.destroyed?).to be true

        expect(HubspotLegacy::Engagement.find(engagement.id)).to be_nil
      end
    end
  end
end
