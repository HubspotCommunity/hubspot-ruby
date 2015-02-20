describe Hubspot::ContactList do
  let(:example_contact_list_hash) do
    VCR.use_cassette("contact_list_example", record: :none) do
      HTTParty.get("https://api.hubapi.com/contacts/v1/lists/1?hapikey=demo").parsed_response
    end
  end

  describe '#initialize' do
    subject { Hubspot::ContactList.new(example_contact_list_hash) }
  	
    it { should be_an_instance_of Hubspot::ContactList }
    its(:id) { should be_an(Integer) }
    its(:portal_id) { should be_a(Integer) }
    its(:name) { should_not be_empty }
    its(:properties) { should be_a(Hash) }
  end	

  before { Hubspot.configure(hapikey: "demo") }

  describe '#contacts' do
    cassette 'contacts_among_list'

    let(:list) { Hubspot::ContactList.new(example_contact_list_hash) }

    it 'returns by defaut 20 contact lists' do
      expect(list.contacts.count).to eql 20
      contact = list.contacts.first
      expect(contact).to be_a(Hubspot::Contact)
    end

    #TODO: add support method to test generic offsets and count options + refactor specs

    it 'add default properties to the contacts returned' do
      contact = list.contacts.first
      expect(contact.email).to_not be_empty 
    end

    it 'caches the result if not explicitely bypassed' do
      pending 'that feature can be removed'
    end
  end

  describe '.all' do
    cassette 'find_all_contacts'

    it 'returns by defaut 20 contact lists' do
      lists = Hubspot::ContactList.all  
      expect(lists.count).to eql 20	

      list = lists.first
      expect(list).to be_a(Hubspot::ContactList) 	
      expect(list.id).to be_an(Integer)
  	end

  	#TODO: add support method to test generic offsets and count options + refactor specs
  end
  
  describe '.find' do
    cassette "contact_list_find"
    subject { Hubspot::ContactList.find(id) }

    context 'when the contact list is found' do
      let(:id) { 1 }
      it { should be_an_instance_of Hubspot::ContactList }
      its(:name) { should == 'twitterers' }
    end

    context 'when the contact list is not found' do
      let(:id) { -1 }
      it { should be_nil }
    end
  end
end