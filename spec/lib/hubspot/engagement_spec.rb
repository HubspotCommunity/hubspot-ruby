describe HubSpot::Engagement do
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
  before{ HubSpot.configure(hapikey: "demo") }

  describe "#initialize" do
    subject{ HubSpot::Engagement.new(example_engagement_hash) }
    it  { should be_an_instance_of HubSpot::Engagement }
    its (:id) { should == 51484873 }
  end

  describe 'EngagementNote' do
    describe ".create!" do
      cassette "engagement_create"
      body = "Test note"
      subject { HubSpot::EngagementNote.create!(nil, body) }
      its(:id) { should_not be_nil }
      its(:body) { should eql body }
    end

    describe ".find" do
      cassette "engagement_find"
      let(:engagement) {HubSpot::EngagementNote.new(example_engagement_hash)}

      it 'must find by the engagement id' do
        find_engagement = HubSpot::EngagementNote.find(engagement.id)
        find_engagement.id.should eql engagement.id
        find_engagement.body.should eql engagement.body
      end
    end

    describe ".find_by_company" do
      cassette "engagement_find_by_country"
      let(:engagement) {HubSpot::EngagementNote.new(example_associated_engagement_hash)}

      it 'must find by company id' do
        find_engagements = HubSpot::EngagementNote.find_by_company(engagement.associations["companyIds"].first)
        find_engagements.should_not be_nil
        find_engagements.any?{|engagement| engagement.id == engagement.id and engagement.body == engagement.body}.should be_true
      end
    end

    describe ".find_by_contact" do
      cassette "engagement_find_by_contact"
      let(:engagement) {HubSpot::EngagementNote.new(example_associated_engagement_hash)}

      it 'must find by contact id' do
        find_engagements = HubSpot::EngagementNote.find_by_contact(engagement.associations["contactIds"].first)
        find_engagements.should_not be_nil
        find_engagements.any?{|engagement| engagement.id == engagement.id and engagement.body == engagement.body}.should be_true
      end
    end

    describe ".find_by_association" do
      cassette "engagement_find_by_association"

      it 'must raise for fake association type' do
        expect {
          HubSpot::EngagementNote.find_by_association(1, 'FAKE_TYPE')
        }.to raise_error
      end
    end

    describe '#destroy!' do
      cassette 'engagement_destroy'

      let(:engagement) {HubSpot::EngagementNote.create!(nil, 'test note') }

      it 'should remove from hubspot' do
        expect(HubSpot::Engagement.find(engagement.id)).to_not be_nil

        expect(engagement.destroy!).to be_true
        expect(engagement.destroyed?).to be_true

        expect(HubSpot::Engagement.find(engagement.id)).to be_nil
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
      subject { HubSpot::EngagementCall.create!(nil, body, 0) }
      its(:id) { should_not be_nil }
      its(:body) { should eql body }
    end

    describe ".find" do
      cassette "engagement_call_find"
      let(:engagement) { HubSpot::EngagementNote.new(example_engagement_hash) }

      it 'must find by the engagement id' do
        find_engagement = HubSpot::EngagementNote.find(engagement.id)
        find_engagement.id.should eql engagement.id
        find_engagement.body.should eql engagement.body
      end
    end

    describe '#destroy!' do
      cassette 'engagement_call_destroy'

      let(:engagement) { HubSpot::EngagementCall.create!(nil, 'test call', 0) }

      it 'should remove from hubspot' do
        expect(HubSpot::Engagement.find(engagement.id)).to_not be_nil

        expect(engagement.destroy!).to be_true
        expect(engagement.destroyed?).to be_true

        expect(HubSpot::Engagement.find(engagement.id)).to be_nil
      end
    end
  end
end
