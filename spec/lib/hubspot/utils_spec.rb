describe Hubspot::Utils do
  describe ".properties_to_hash" do
    let(:properties) do
      {
        "email"     => { "value" => "email@address.com" },
        "firstname" => { "value" => "Bob" },
        "lastname"  => { "value" => "Smith" }
      }
    end
    subject { Hubspot::Utils.properties_to_hash(properties) }
    its(["email"]) { should == "email@address.com" }
    its(["firstname"]) { should == "Bob" }
    its(["lastname"]) { should == "Smith" }
  end

  describe ".hash_to_properties" do
    let(:hash) do
      {
        "email"     => "email@address.com",
        "firstname" => "Bob",
        "lastname"  => "Smith"
      }
    end
    subject { Hubspot::Utils.hash_to_properties(hash) }
    it { should be_an_instance_of Array }
    its(:length) { should == 3 }
    it { should include({ "property" => "email", "value" => "email@address.com" }) }
    it { should include({ "property" => "firstname", "value" => "Bob" }) }
    it { should include({ "property" => "lastname", "value" => "Smith" }) }
  end

  describe '.compare_property_lists for ContactProperties' do
    let(:example_groups) do
      VCR.use_cassette('groups_example', record: :none) do
        HTTParty.get('https://api.hubapi.com/contacts/v2/groups?hapikey=demo').parsed_response
      end
    end

    let(:example_properties) do
      VCR.use_cassette('properties_example', record: :none) do
        HTTParty.get('https://api.hubapi.com/contacts/v2/properties?hapikey=demo').parsed_response
      end
    end

    let(:source) { { 'groups' => example_groups, 'properties' => example_properties } }
    let!(:target) { Marshal.load(Marshal.dump(source)) }

    context 'with no changes' do
      it 'should report no changes' do
        skip, new_groups, new_props, update_props = Hubspot::Utils.compare_property_lists(Hubspot::ContactProperties, source, target)
        expect(skip.count).to be > 0
        expect(new_groups.count).to be(0)
        expect(new_props.count).to be(0)
        expect(update_props.count).to be(0)
      end
    end

    context 'with changes' do
      let(:description) { "#{source['properties'][0]['description']}_XXX" }

      count = 0

      it 'should report the changes' do
        10.times do |i|
          if !source['properties'][i]['readOnlyDefinition']
            source['properties'][i]['description']   = description
            source['properties'][i]['createdUserId'] = 2500
            count                                    += 1
          end
        end

        skip, new_groups, new_props, update_props = Hubspot::Utils.compare_property_lists(Hubspot::ContactProperties, source, target)
        expect(skip.count).to be > 0
        expect(new_groups.count).to be(0)
        expect(new_props.count).to be(0)
        expect(update_props.count).to be(count)
      end
    end
  end

  describe '.compare_property_lists for DealProperties' do
    let(:example_groups) do
      VCR.use_cassette('deal_groups_example', record: :none) do
        HTTParty.get('https://api.hubapi.com/deals/v1/groups?hapikey=demo').parsed_response
      end
    end

    let(:example_properties) do
      VCR.use_cassette('deal_properties_example', record: :none) do
        HTTParty.get('https://api.hubapi.com/deals/v1/properties?hapikey=demo').parsed_response
      end
    end

    let(:source) { { 'groups' => example_groups, 'properties' => example_properties } }
    let!(:target) { Marshal.load(Marshal.dump(source)) }

    context 'with no changes' do
      it 'should report no changes' do
        skip, new_groups, new_props, update_props = Hubspot::Utils.compare_property_lists(Hubspot::DealProperties, source, target)
        expect(skip.count).to be > 0
        expect(new_groups.count).to be(0)
        expect(new_props.count).to be(0)
        expect(update_props.count).to be(0)
      end
    end

    context 'with changes' do
      let(:description) { "#{source['properties'][0]['description']}_XXX" }

      count = 0

      it 'should report the changes' do
        10.times do |i|
          if !source['properties'][i]['readOnlyDefinition']
            source['properties'][i]['description']   = description
            source['properties'][i]['createdUserId'] = 2500
            count                                    += 1
          end
        end

        skip, new_groups, new_props, update_props = Hubspot::Utils.compare_property_lists(Hubspot::DealProperties, source, target)
        expect(skip.count).to be > 0
        expect(new_groups.count).to be(0)
        expect(new_props.count).to be(0)
        expect(update_props.count).to be(count)
      end
    end
  end
end
