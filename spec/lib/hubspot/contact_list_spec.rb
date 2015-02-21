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
    its(:dynamic) { should be true } 
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
      pending 'that feature can be removed + cf. refresh api endpoint'
    end
  end

  describe '.all' do
  	#TODO: add support method to test generic offsets and count options for each context + refactor spec

    context 'all list types' do
      cassette 'find_all_lists'

      it 'returns by defaut 20 contact lists' do
        lists = Hubspot::ContactList.all  
        expect(lists.count).to eql 20	

        list = lists.first
        expect(list).to be_a(Hubspot::ContactList) 	
        expect(list.id).to be_an(Integer)
  	  end
    end

    context 'static lists' do 
      cassette 'find_all_stastic_lists'

      it 'returns by defaut all the static contact lists' do
      	lists = Hubspot::ContactList.all(static: true)  
        expect(lists.count).to be > 20	

        list = lists.first
        expect(list).to be_a(Hubspot::ContactList) 
        expect(list.dynamic).to be false
      end
    end

    context 'dynamic lists' do
      cassette 'find_all_dynamic_lists'
     
      it 'returns by defaut all the static contact lists' do
      	lists = Hubspot::ContactList.all(dynamic: true)  
        expect(lists.count).to be > 20

        list = lists.first
        expect(list).to be_a(Hubspot::ContactList)
        expect(list.dynamic).to be true
      end
    end
  end
  
  describe '.find' do
    context 'given an id' do
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

    context 'given a list of ids' do
      cassette "contact_list_batch_find"

      it 'find lists of contacts' do
      	lists = Hubspot::ContactList.find([2,3,4])
      	list = lists.first
      	expect(list).to be_a(Hubspot::ContactList)
      	expect(list.id).to be == 2
      	expect(lists.second.id).to be == 3
      	expect(lists.last.id).to be == 4
      end
    end
  end
end