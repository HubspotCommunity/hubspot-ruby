describe 'Contact Properties API Live test', live: true do
  # Let's try to hit all the API endpoints at least once

  before do
    Hubspot.configure hapikey: "demo"
  end

  it 'should return a list of properties' do
    result = Hubspot::ContactProperties.all

    expect(result.count).to be > 0
  end

  it 'should return a list of properties for the specified groups' do
    group_names = %w(contactinformation salesforceinformation)

    result = Hubspot::ContactProperties.all({}, { include: group_names })
    expect(result.count).to be > 0
    result.each do |entry|
      expect(group_names.include?(entry['groupName']))
    end
  end

  it 'should return a list of properties except for the specified groups' do
    group_names = %w(contactinformation salesforceinformation)

    result = Hubspot::ContactProperties.all({}, { exclude: group_names })
    expect(result.count).to be > 0
    result.each do |entry|
      expect(group_names.include?(entry['groupName'])).to be_false
    end
  end

  it 'should return a list of groups' do
    result = Hubspot::ContactProperties.groups

    expect(result.count).to be > 0
    expect(result[0].slice(*%w(name displayName displayOrder)).count).to eq(3)
  end

  it 'should return  list of groups and their properties' do
    result = Hubspot::ContactProperties.groups({ includeProperties: true })

    expect(result.count).to be > 0
    expect(result[0].slice(*%w(name displayName displayOrder properties)).count).to eq(4)
  end

  it 'should return only the requested groups' do
    group_names = %w(contactinformation salesforceinformation)
    result      = Hubspot::ContactProperties.groups({}, { include: group_names })

    expect(result.count).to eq(group_names.count)
    result.each do |entry|
      expect(group_names.include?(entry['name']))
    end
  end

  it 'should filter out the excluded groups' do
    group_names = %w(contactinformation salesforceinformation)
    result      = Hubspot::ContactProperties.groups({}, { exclude: group_names })

    result.each do |entry|
      expect(group_names.include?(entry['name'])).to be_false
    end
  end

  describe 'should create, update, and delete properties' do
    let(:data) {
      { 'name'        => 'testfield909',
        'label'       => 'A test property',
        'description' => 'This is a test property',
        'groupName'   => 'contactinformation',
        'type'        => 'string',
        'fieldType'   => 'text',
        'formField'   => false }
    }

    it 'should create a new property' do
      response = Hubspot::ContactProperties.create!(data)
      data.map { |key, val| expect(response[key]).to eql(val) }
    end

    it 'should update an existing property' do
      data['label'] = 'An updated test property'

      response = Hubspot::ContactProperties.update!(data['name'], data)
      data.map { |key, val| expect(response[key]).to eql(val) }
    end

    it 'should delete an existing property' do
      response = Hubspot::ContactProperties.delete!(data['name'])
      expect(response).to be nil
    end
  end

  describe 'should create, update, and delete property groups' do
    let(:data) {
      { 'name'         => 'testgroup99',
        'displayName'  => 'Test Group 99'
      }
    }

    it 'should create a new property group' do
      response = Hubspot::ContactProperties.create_group!(data)
      data.map { |key, val| expect(response[key]).to eql(val) }
    end

    it 'should update an existing property group' do
      data['displayName'] = 'Test Group 99 Modified'

      response = Hubspot::ContactProperties.update_group!(data['name'], data)
      data.map { |key, val| expect(response[key]).to eql(val) }
    end

    it 'should delete an existing property group' do
      response = Hubspot::ContactProperties.delete_group!(data['name'])
      expect(response).to be nil
    end
  end
end
