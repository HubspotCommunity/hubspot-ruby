describe Hubspot::ContactList do
  let(:example_contact_list_hash) do
    VCR.use_cassette("contact_list_example") do
      HTTParty.get("https://api.hubapi.com/contacts/v1/lists/1?hapikey=demo").parsed_response
    end
  end

  let(:static_list) { Hubspot::ContactList.all(static: true, count: 3).last }
  let(:dynamic_list) { Hubspot::ContactList.all(dynamic: true, count: 1).first }

  let(:example_contact_hash) do
    VCR.use_cassette("contact_example") do
      HTTParty.get("https://api.hubapi.com/contacts/v1/contact/email/testingapis@hubspot.com/profile?hapikey=demo").parsed_response
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

    it 'returns by default 20 contact lists' do
      expect(list.contacts.count).to eql 20
      contact = list.contacts.first
      expect(contact).to be_a(Hubspot::Contact)
    end

    it 'returns by default 20 contact lists with paging data' do
      contact_data = list.contacts({paged: true})
      contacts = contact_data['contacts']

      expect(contact_data).to have_key 'vid-offset'
      expect(contact_data).to have_key 'has-more'

      expect(contacts.count).to eql 20
      contact = contacts.first
      expect(contact).to be_a(Hubspot::Contact)
    end

    it 'add default properties to the contacts returned' do
      contact = list.contacts.first
      expect(contact.email).to_not be_empty
    end

    expect_count_and_offset do |params|
      Hubspot::ContactList.find(1).contacts(params)
    end
  end

  describe '.create' do
    subject{ Hubspot::ContactList.create!({ name: name }) }

    context 'with all required parameters' do
      cassette 'create_list'

      let(:name) { 'testing list' }
      it { should be_an_instance_of Hubspot::ContactList }
      its(:id) { should be_an(Integer) }
      its(:portal_id) { should be_an(Integer) }
      its(:dynamic) { should be false }

      context 'adding filters parameters' do
        cassette 'create_list_with_filters'

        it 'returns a ContactList object with filters set' do
          name = 'list with filters'
          filters_param = [[{ operator: "EQ", value: "@hubspot", property: "twitterhandle", type: "string"}]]
          list_with_filters = Hubspot::ContactList.create!({ name: name, filters: filters_param })
          expect(list_with_filters).to be_a(Hubspot::ContactList)
          expect(list_with_filters.properties['filters']).to_not be_empty
        end
      end
    end

    context 'without all required parameters' do
      cassette 'fail_to_create_list'

      it 'raises an error' do
        expect { Hubspot::ContactList.create!({ name: nil }) }.to raise_error(Hubspot::RequestError)
      end
    end
  end

  describe '.all' do
    context 'all list types' do
      cassette 'find_all_lists'

      it 'returns by default 20 contact lists' do
        lists = Hubspot::ContactList.all
        expect(lists.count).to eql 20

        list = lists.first
        expect(list).to be_a(Hubspot::ContactList)
        expect(list.id).to be_an(Integer)
      end

      expect_count_and_offset { |params| Hubspot::ContactList.all(params) }
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

        let(:id) { '1' }
        it { should be_an_instance_of Hubspot::ContactList }
      end

      context 'Wrong parameter type given' do
        it 'raises an error' do
          expect { Hubspot::ContactList.find(static_list) }.to raise_error(Hubspot::InvalidParams)
        end
      end

      context 'when the contact list is not found' do
        it 'raises an error' do
          expect { Hubspot::ContactList.find(-1) }.to raise_error(Hubspot::RequestError)
        end
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

  describe "#add" do
    context "for a static list" do
      it "adds the contact to the contact list" do
        VCR.use_cassette("contact_lists/add_contact") do
          contact = Hubspot::Contact.create!("email@example.com")
          contact_list_params = { name: "my-contacts-list" }
          contact_list = Hubspot::ContactList.create!(contact_list_params)

          result = contact_list.add([contact])

          expect(result).to be true

          contact.destroy!
          contact_list.destroy!
        end
      end

      context "when the contact already exists in the contact list" do
        it "returns false" do
          VCR.use_cassette("contact_lists/add_existing_contact") do
            contact = Hubspot::Contact.create!("email@example.com")

            contact_list_params = { name: "my-contacts-list" }
            contact_list = Hubspot::ContactList.create!(contact_list_params)
            contact_list.add([contact])

            result = contact_list.add([contact])

            expect(result).to be false

            contact.destroy!
            contact_list.destroy!
          end
        end
      end
    end

    context "for a dynamic list" do
      it "raises an error as dynamic lists add contacts via on filters" do
        VCR.use_cassette("contact_list/add_contact_to_dynamic_list") do
          contact = Hubspot::Contact.create!("email@example.com")
          contact_list_params = {
            name: "my-contacts-list",
            dynamic: true,
            "filters": [
              [
                {
                  "operator": "EQ",
                  "property": "email",
                  "type": "string",
                  "value": "@hubspot.com"
                },
              ],
            ],
          }
          contact_list = Hubspot::ContactList.create!(contact_list_params)

          expect {
            contact_list.add(contact)
          }.to raise_error(Hubspot::RequestError)
        end
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
        contact_not_present_in_list = Hubspot::Contact.new(example_contact_hash)
        expect(static_list.remove(contact_not_present_in_list)).to be false
      end
    end

    context 'dynamic list' do
      it 'raises error if try to remove a contact from a dynamic list' do
        contact = dynamic_list.contacts(recent: true, count: 1).first
        expect { dynamic_list.remove(contact) }.to raise_error(Hubspot::RequestError)
      end
    end
  end

  describe '#update!' do
    cassette "contact_list_update"

    let(:contact_list) { Hubspot::ContactList.new(example_contact_list_hash) }
    let(:params) { { name: "update list name" } }
    subject { contact_list.update!(params) }

    it { should be_an_instance_of Hubspot::ContactList }
    its(:name){ should == "update list name" }
  end

  describe '#destroy!' do
    cassette "contact_list_destroy"

    let(:contact_list) { Hubspot::ContactList.create!({ name: "newcontactlist_#{Time.now.to_i}"}) }
    subject{ contact_list.destroy! }
    it { should be true }

    it "should be destroyed" do
      subject
      expect(contact_list).to be_destroyed
    end
  end

  describe '#refresh' do
    cassette "contact_list_refresh"

    let(:contact_list) { Hubspot::ContactList.new(example_contact_list_hash) }
    subject { contact_list.refresh }

    it { should be true }
  end
end
