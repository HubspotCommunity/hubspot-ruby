describe HubSpot::ContactList do
  let(:example_contact_list_hash) do
    VCR.use_cassette("contact_list_example", record: :none) do
      HTTParty.get("https://api.hubapi.com/contacts/v1/lists/1?hapikey=demo").parsed_response
    end
  end

  let(:static_list) { HubSpot::ContactList.all(static: true, count: 3).last }
  let(:dynamic_list) { HubSpot::ContactList.all(dynamic: true, count: 1).first }

  let(:example_contact_hash) do
    VCR.use_cassette("contact_example", record: :none) do
      HTTParty.get("https://api.hubapi.com/contacts/v1/contact/email/testingapis@hubspot.com/profile?hapikey=demo").parsed_response
    end
  end

  describe '#initialize' do
    subject { HubSpot::ContactList.new(example_contact_list_hash) }

    it { should be_an_instance_of HubSpot::ContactList }
    its(:id) { should be_an(Integer) }
    its(:portal_id) { should be_a(Integer) }
    its(:name) { should_not be_empty }
    its(:dynamic) { should be true }
    its(:properties) { should be_a(Hash) }
  end

  before { HubSpot.configure(hapikey: "demo") }

  describe '#contacts' do
    cassette 'contacts_among_list'

    let(:list) { HubSpot::ContactList.new(example_contact_list_hash) }

    it 'returns by default 20 contact lists' do
      expect(list.contacts.count).to eql 20
      contact = list.contacts.first
      expect(contact).to be_a(HubSpot::Contact)
    end

    it 'returns by default 20 contact lists with paging data' do
      contact_data = list.contacts({paged: true})
      contacts = contact_data['contacts']

      expect(contact_data).to have_key 'vid-offset'
      expect(contact_data).to have_key 'has-more'

      expect(contacts.count).to eql 20
      contact = contacts.first
      expect(contact).to be_a(HubSpot::Contact)
    end

    it 'add default properties to the contacts returned' do
      contact = list.contacts.first
      expect(contact.email).to_not be_empty
    end

    expect_count_and_offset do |params|
      HubSpot::ContactList.find(1).contacts(params)
    end
  end

  describe '.create' do
    subject{ HubSpot::ContactList.create!({ name: name }) }

    context 'with all required parameters' do
      cassette 'create_list'

      let(:name) { 'testing list' }
      it { should be_an_instance_of HubSpot::ContactList }
      its(:id) { should be_an(Integer) }
      its(:portal_id) { should be_an(Integer) }
      its(:dynamic) { should be false }

      context 'adding filters parameters' do
        cassette 'create_list_with_filters'

        it 'returns a ContactList object with filters set' do
          name = 'list with filters'
          filters_param = [[{ operator: "EQ", value: "@hubspot", property: "twitterhandle", type: "string"}]]
          list_with_filters = HubSpot::ContactList.create!({ name: name, filters: filters_param })
          expect(list_with_filters).to be_a(HubSpot::ContactList)
          expect(list_with_filters.properties['filters']).to_not be_empty
        end
      end
    end

    context 'without all required parameters' do
      cassette 'fail_to_create_list'

      it 'raises an error' do
        expect { HubSpot::ContactList.create!({ name: nil }) }.to raise_error(HubSpot::RequestError)
      end
    end
  end

  describe '.all' do
    context 'all list types' do
      cassette 'find_all_lists'

      it 'returns by default 20 contact lists' do
        lists = HubSpot::ContactList.all
        expect(lists.count).to eql 20

        list = lists.first
        expect(list).to be_a(HubSpot::ContactList)
        expect(list.id).to be_an(Integer)
      end

      expect_count_and_offset { |params| HubSpot::ContactList.all(params) }
    end

    context 'static lists' do
      cassette 'find_all_stastic_lists'

      it 'returns by defaut all the static contact lists' do
      	lists = HubSpot::ContactList.all(static: true)
        expect(lists.count).to be > 20

        list = lists.first
        expect(list).to be_a(HubSpot::ContactList)
        expect(list.dynamic).to be false
      end
    end

    context 'dynamic lists' do
      cassette 'find_all_dynamic_lists'

      it 'returns by defaut all the static contact lists' do
      	lists = HubSpot::ContactList.all(dynamic: true)
        expect(lists.count).to be > 20

        list = lists.first
        expect(list).to be_a(HubSpot::ContactList)
        expect(list.dynamic).to be true
      end
    end
  end

  describe '.find' do
    context 'given an id' do
      cassette "contact_list_find"
      subject { HubSpot::ContactList.find(id) }

      context 'when the contact list is found' do
        let(:id) { 1 }
        it { should be_an_instance_of HubSpot::ContactList }
        its(:name) { should == 'twitterers' }

        let(:id) { '1' }
        it { should be_an_instance_of HubSpot::ContactList }
      end

      context 'Wrong parameter type given' do
        it 'raises an error' do
          expect { HubSpot::ContactList.find(static_list) }.to raise_error(HubSpot::InvalidParams)
        end
      end

      context 'when the contact list is not found' do
        it 'raises an error' do
          expect { HubSpot::ContactList.find(-1) }.to raise_error(HubSpot::RequestError)
        end
      end
    end

    context 'given a list of ids' do
      cassette "contact_list_batch_find"

      it 'find lists of contacts' do
        lists = HubSpot::ContactList.find([2,3,4])
        list = lists.first
        expect(list).to be_a(HubSpot::ContactList)
        expect(list.id).to be == 2
        expect(lists.second.id).to be == 3
        expect(lists.last.id).to be == 4
      end
    end
  end

  describe '#add' do
    cassette "add_contacts_to_lists"

    context 'static list' do
      it 'returns true if contacts have been added to the list' do
        contact = HubSpot::Contact.all(count: 1).first
        mock(HubSpot::Connection).post_json("/contacts/v1/lists/:list_id/add", {:params=>{:list_id=>4}, :body=>{:vids=>[contact.vid]}}) { { 'updated' => [contact.vid] } }

        expect(static_list.add(contact)).to be true
      end

      it 'returns false if the contact already exists in the list' do
        contact = static_list.contacts(count: 1).first
        expect(static_list.add(contact)).to be false
      end
    end

    context 'dynamic list' do
      it 'raises error if try to add a contact to a dynamic list' do
        contact = HubSpot::Contact.new(example_contact_hash)
        expect { dynamic_list.add(contact) }.to raise_error(HubSpot::RequestError)
      end
    end
  end

  describe '#remove' do
    cassette "remove_contacts_from_lists"

    context 'static list' do
      it 'returns true if removes all contacts in batch mode' do
        contacts = static_list.contacts(count: 2)
        expect(static_list.remove([contacts.first, contacts.last])).to be true
      end

      it 'returns false if the contact cannot be removed' do
        contact_not_present_in_list = HubSpot::Contact.new(example_contact_hash)
        expect(static_list.remove(contact_not_present_in_list)).to be false
      end
    end

    context 'dynamic list' do
      it 'raises error if try to remove a contact from a dynamic list' do
        contact = dynamic_list.contacts(recent: true, count: 1).first
        expect { dynamic_list.remove(contact) }.to raise_error(HubSpot::RequestError)
      end
    end
  end

  describe '#update!' do
    cassette "contact_list_update"

    let(:contact_list) { HubSpot::ContactList.new(example_contact_list_hash) }
    let(:params) { { name: "update list name" } }
    subject { contact_list.update!(params) }

    it { should be_an_instance_of HubSpot::ContactList }
    its(:name){ should == "update list name" }
  end

  describe '#destroy!' do
    cassette "contact_list_destroy"

    let(:contact_list) { HubSpot::ContactList.create!({ name: "newcontactlist_#{Time.now.to_i}"}) }
    subject{ contact_list.destroy! }
    it { should be_true }

    it "should be destroyed" do
      subject
      contact_list.destroyed?.should be_true
    end
  end

  describe '#refresh' do
    cassette "contact_list_refresh"

    let(:contact_list) { HubSpot::ContactList.new(example_contact_list_hash) }
    subject { contact_list.refresh }

    it { should be true }
  end
end
