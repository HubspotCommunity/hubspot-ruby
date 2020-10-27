describe HubspotLegacy::Topic do
  before do
    HubspotLegacy.configure(hapikey: "demo")
  end

  describe ".list" do
    cassette "topics_list"
    let(:topics) { HubspotLegacy::Topic.list }

    it "should have a list of topics" do
      topics.count.should be(3)
    end
  end

  describe ".find_by_topic_id" do
    cassette "topics_list"

    it "should find a specific topic" do
      topic = HubspotLegacy::Topic.find_by_topic_id(349001328)
      topic['id'].should eq(349001328)
    end
  end
end
