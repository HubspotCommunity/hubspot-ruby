describe Hubspot::CompanyProperties do
  describe '.add_default_parameters' do
    subject { Hubspot::CompanyProperties.add_default_parameters({}) }
    context 'default parameters' do
      its([:property]) { should == 'email' }
    end
  end

  let(:example_groups) do
    VCR.use_cassette('groups_example', record: :once) do
      HTTParty.get('https://api.hubapi.com/companies/v2/groups?hapikey=demo').parsed_response
    end
  end

  let(:example_properties) do
    VCR.use_cassette('properties_example', record: :once) do
      HTTParty.get('https://api.hubapi.com/companies/v2/properties?hapikey=demo').parsed_response
    end
  end

  before { Hubspot.configure(hapikey: 'demo') }

  describe 'Properties' do
    describe '.all' do
      context 'with no filter' do
        cassette 'all_properties'

        it 'should return all properties' do
          expect(Hubspot::CompanyProperties.all).to eql(example_properties)
        end
      end

      let(:groups) { %w(calltrackinginfo emailinformation) }

      context 'with included groups' do
        cassette 'properties_in_groups'

        it 'should return properties for the specified group[s]' do
          response = Hubspot::CompanyProperties.all({}, { include: groups })
          response.each { |p| expect(groups.include?(p['groupName'])).to be_true }
        end
      end

      context 'with excluded groups' do
        cassette 'properties_not_in_groups'

        it 'should return properties for the non-specified group[s]' do
          response = Hubspot::CompanyProperties.all({}, { exclude: groups })
          response.each { |p| expect(groups.include?(p['groupName'])).to be_false }
        end
      end
    end

    let(:params) { {
      'name'                          => 'my_new_property',
      'label'                         => 'This is my new property',
      'description'                   => 'What kind of x would you like?',
      'groupName'                     => 'companyinformation',
      'type'                          => 'string',
      'fieldType'                     => 'text',
      'hidden'                        => false,
      'options'                       => [],
      'deleted'                       => false,
      'displayOrder'                  => 0,
      'formField'                     => true,
      'readOnlyValue'                 => false,
      'readOnlyDefinition'            => false,
      'mutableDefinitionNotDeletable' => false,
      'calculated'                    => false,
      'externalOptions'               => false,
      'displayMode'                   => 'current_value'
    } }
    let(:valid_params) { params.select { |k, _| Hubspot::CompanyProperties::PROPERTY_SPECS[:field_names].include?(k) } }

    describe '.create!' do
      context 'with no valid parameters' do
        cassette 'fail_to_create_property'

        it 'should return nil' do
          expect(Hubspot::CompanyProperties.create!({})).to be(nil)
        end
      end

      context 'with all valid parameters' do
        cassette 'create_property'

        it 'should return the valid parameters' do
          response = Hubspot::CompanyProperties.create!(params)
          valid_params.each { |k, v| expect(response[k]).to eq(v) }
        end
      end
    end

    describe '.update!' do
      context 'with no valid parameters' do

        it 'should return nil ' do
          expect(Hubspot::CompanyProperties.update!(params['name'], {})).to be(nil)
        end
      end

      context 'with mixed parameters' do
        cassette 'update_property'

        it 'should return the valid parameters' do
          params['description']       = 'What is their favorite flavor?'
          valid_params['description'] = params['description']

          response = Hubspot::CompanyProperties.update!(params['name'], params)
          valid_params.each { |k, v| expect(response[k]).to eq(v) }
        end
      end
    end

    describe '.delete!' do
      let(:name) { params['name'] }

      context 'with existing property' do
        cassette 'delete_property'

        it 'should return nil' do
          expect(Hubspot::CompanyProperties.delete!(name)).to eq(nil)
        end
      end

      context 'with non-existent property' do
        cassette 'delete_non_property'

        it 'should raise an error' do
          expect { Hubspot::CompanyProperties.delete!(name) }.to raise_error(Hubspot::RequestError)
        end
      end
    end
  end

  describe 'Groups' do
    describe '.groups' do
      context 'with no filter' do
        cassette 'all_groups'

        it 'should return all groups' do
          expect(Hubspot::CompanyProperties.groups).to eql(example_groups)
        end
      end

      let(:groups) { %w(calltrackinginfo emailinformation) }

      context 'with included groups' do
        cassette 'groups_included'

        it 'should return the specified groups' do
          response = Hubspot::CompanyProperties.groups({}, { include: groups })
          response.each { |p| expect(groups.include?(p['name'])).to be_true }
        end
      end

      context 'with excluded groups' do
        cassette 'groups_not_excluded'

        it 'should return groups that were not excluded' do
          response = Hubspot::CompanyProperties.groups({}, { exclude: groups })
          response.each { |p| expect(groups.include?(p['name'])).to be_false }
        end
      end
    end

    let(:params) { { 'name' => 'ff_group1', 'displayName' => 'Test Group One', 'displayOrder' => 100, 'badParam' => 99 } }

    describe '.create_group!' do
      context 'with no valid parameters' do
        it 'should return nil' do
          expect(Hubspot::CompanyProperties.create_group!({})).to be(nil)
        end
      end

      context 'with mixed parameters' do
        cassette 'create_group'

        it 'should return the valid parameters' do
          response = Hubspot::CompanyProperties.create_group!(params)
          expect(Hubspot::CompanyProperties.same?(response, params)).to be_true
        end
      end

      context 'with some valid parameters' do
        cassette 'create_group_some_params'

        let(:sub_params) { params.select { |k, _| k != 'displayName' } }

        it 'should return the valid parameters' do
          params['name'] = 'ff_group235'
          response       = Hubspot::CompanyProperties.create_group!(sub_params)
          expect(Hubspot::CompanyProperties.same?(response, sub_params)).to be_true
        end
      end
    end

    describe '.update_group!' do
      context 'with no valid parameters' do

        it 'should return nil ' do
          expect(Hubspot::CompanyProperties.update_group!(params['name'], {})).to be(nil)
        end
      end

      context 'with mixed parameters' do
        cassette 'update_group'

        it 'should return the valid parameters' do
          params['displayName'] = 'Test Group OneA'

          response = Hubspot::CompanyProperties.update_group!(params['name'], params)
          expect(Hubspot::CompanyProperties.same?(response, params)).to be_true
        end
      end

    end

    describe '.delete_group!' do
      let(:name) { params['name'] }

      context 'with existing group' do
        cassette 'delete_group'

        it 'should return nil' do
          expect(Hubspot::CompanyProperties.delete_group!(name)).to eq(nil)
        end
      end

      context 'with non-existent group' do
        cassette 'delete_non_group'

        it 'should raise an error' do
          expect { Hubspot::CompanyProperties.delete_group!(name) }.to raise_error(Hubspot::RequestError)
        end
      end
    end
  end
end
