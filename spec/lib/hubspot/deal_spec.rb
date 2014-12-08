require 'spec_helper'

describe Hubspot::Deal do
  let(:example_deal_hash) do
    VCR.use_cassette("deal_example") do
      HTTParty.get("https://api.hubapi.com/deals/v1/deal/3?hapikey=demo&portalId=62515").parsed_response
    end
  end

  before{ Hubspot.configure(hapikey: "demo") }

  describe "#initialize" do
    subject{ Hubspot::Deal.new(example_deal_hash) }
    it  { should be_an_instance_of Hubspot::Deal }
    its (:portal_id) { should == 62515 }
    its (:deal_id) { should == 3 }
  end

  describe ".create!" do
    cassette "deal_create"
    subject { Hubspot::Deal.create!(62515, [8954037], [27136], {}) }
    its(:deal_id)     { should_not be_nil }
    its(:portal_id)   { should eql 62515 }
    its(:company_ids) { should eql [8954037]}
    its(:vids)        { should eql [27136]}
  end

  describe ".find" do
    cassette "deal_find"
    let(:deal) {Hubspot::Deal.create!(62515, [8954037], [27136], {})}

    it 'must find by the deal id' do
      find_deal = Hubspot::Deal.find(deal.deal_id)
      find_deal.deal_id.should eql deal.deal_id
    end
  end

end