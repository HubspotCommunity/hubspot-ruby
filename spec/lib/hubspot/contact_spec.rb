describe Hubspot::Contact do
  let(:example_contact_hash) do
    VCR.use_cassette('contact_example', record: :none) do
      HTTParty.get('https://api.hubapi.com/contacts/v1/contact/email/testingapis@hubspot.com/profile?hapikey=demo').parsed_response
    end
  end

  before{ Hubspot.configure(hapikey: 'demo') }

  describe '#initialize' do
    subject{ Hubspot::Contact.new(example_contact_hash) }
    it{ should be_an_instance_of Hubspot::Contact }
    its(['email']){ should == 'testingapis@hubspot.com' }
    its(['firstname']){ should == 'Clint' }
    its(['lastname']){ should == 'Eastwood' }
    its(['phone']){ should == '555-555-5432' }
    its(:utk){ should == '1234567890' }
    its(:vid){ should == 82325 }
  end

  describe '.create!' do
    cassette 'contact_create'
    let(:params){{}}
    subject{ Hubspot::Contact.create!(email, params) }
    context 'with a new email' do
      let(:email){ "newcontact#{Time.now.to_i}@hsgem.com" }
      it{ should be_an_instance_of Hubspot::Contact }
      its(:email){ should match /newcontact.*@hsgem.com/ } # Due to VCR the email may not match exactly

      context 'and some params' do
        cassette 'contact_create_with_params'
        let(:email){ "newcontact_x_#{Time.now.to_i}@hsgem.com" }
        let(:params){ {firstname: 'Hugh', lastname: 'Jackman' } }
        its(['firstname']){ should == 'Hugh'}
        its(['lastname']){ should == 'Jackman'}
      end
    end
    context 'with an existing email' do
      cassette 'contact_create_existing_email'
      let(:email){ 'testingapis@hubspot.com' }
      it 'raises a RequestError' do
        expect{ subject }.to raise_error Hubspot::RequestError
      end
    end
    context 'with an invalid email' do
      cassette 'contact_create_invalid_email'
      let(:email){ 'not_an_email' }
      it 'raises a RequestError' do
        expect{ subject }.to raise_error Hubspot::RequestError
      end
    end
  end

  describe '.createOrUpdate' do
    cassette 'contact_create_or_update'
    let(:params){{}}
    subject{ Hubspot::Contact.createOrUpdate(email, params) }
    context 'with a new email' do
      let(:email){ "newcontact#{Time.now.to_i}@hsgem.com" }
      it{ should be_an_instance_of Hubspot::Contact }
      its(:email){ should match /newcontact.*@hsgem.com/ } # Due to VCR the email may not match exactly

      context 'and some params' do
        cassette 'contact_create_or_update_with_params'
        let(:email){ "newcontact_x_#{Time.now.to_i}@hsgem.com" }
        let(:params){ {firstname: 'Hugh', lastname: 'Jackman' } }
        its(['firstname']){ should == 'Hugh'}
        its(['lastname']){ should == 'Jackman'}
      end
    end
    context 'with an existing email' do
      cassette 'contact_create_or_update_existing_email'
      let(:email){ 'testingapis@hubspot.com' }
      let(:params){ { firstname: 'Hugh', lastname: 'Jackman, Jr.' } }
      its(['firstname']){ should == 'Hugh'}
      its(['lastname']){ should == 'Jackman, Jr.'}
    end
    context 'with an invalid email' do
      cassette 'contact_create_or_update_invalid_email'
      let(:email){ 'not_an_email' }
      it 'raises a RequestError' do
        expect{ subject }.to raise_error Hubspot::RequestError
      end
    end
  end

  describe '.create_or_update!' do
    cassette 'create_or_update'
    let(:existing_contact) do
      Hubspot::Contact.create!("morpheus@example.com", firstname: 'Morpheus')
    end
    before do
      Hubspot::Contact.create_or_update!(params)
    end

    let(:params) do
      [
        {
          vid: existing_contact.vid,
          email: existing_contact.email,
          firstname: 'Neo'
        },
        {
          email: 'smith@example.com',
          firstname: 'Smith'
        }
      ]
    end

    it 'creates and updates contacts' do
      contact = Hubspot::Contact.find_by_id existing_contact.vid
      expect(contact.properties['firstname']).to eql 'Neo'
      latest_contact_email = Hubspot::Contact.all(recent: true).first.email
      new_contact = Hubspot::Contact.find_by_email(latest_contact_email)
      expect(new_contact.properties['firstname']).to eql 'Smith'
    end
  end

  describe '.find_by_email' do
    context 'given an uniq email' do
      cassette 'contact_find_by_email'
      subject{ Hubspot::Contact.find_by_email(email) }

      context 'when the contact is found' do
        let(:email){ 'testingapis@hubspot.com' }
        it{ should be_an_instance_of Hubspot::Contact }
        its(:vid){ should == 82325 }
      end

      context 'when the contact cannot be found' do
        it 'raises an error' do
          expect { Hubspot::Contact.find_by_email('notacontact@test.com') }.to raise_error(Hubspot::RequestError)
        end
      end
    end

    context 'batch mode' do
      cassette 'contact_find_by_email_batch_mode'

      it 'find lists of contacts' do
        emails = ['testingapis@hubspot.com', 'testingapisawesomeandstuff@hubspot.com']
        contacts = Hubspot::Contact.find_by_email(emails)
        pending
      end
    end
  end

  describe '.find_by_id' do
    before do
      @s = StringIO.new
      Hubspot::Config.logger = Logger.new(@s)
    end

    context 'given an uniq id' do
      cassette 'contact_find_by_id'
      subject{ Hubspot::Contact.find_by_id(vid) }

      context 'when the contact is found' do
        let(:vid){ 82325 }
        it{ should be_an_instance_of Hubspot::Contact }
        its(:email){ should == 'testingapis@hubspot.com' }
      end

      context 'when the contact cannot be found' do
        it 'raises an error' do
          expect { Hubspot::Contact.find_by_id(9999999) }.to raise_error(Hubspot::RequestError)
          expect(@s.string).to include 'Response: 404'
        end
      end
    end

    context 'batch mode' do
      cassette 'contact_find_by_id_batch_mode'

      # NOTE: error currently appends on API endpoint
      it 'find lists of contacts' do
        expect { Hubspot::Contact.find_by_id([82325]) }.to raise_error(Hubspot::ApiError)
        expect(@s.string).to include('Response: 200')
      end
    end
  end

  describe '.find_by_utk' do
    context 'given an uniq utk' do
      cassette 'contact_find_by_utk'
      subject{ Hubspot::Contact.find_by_utk(utk) }

      context 'when the contact is found' do
        let(:utk){ 'f844d2217850188692f2610c717c2e9b' }
        it{ should be_an_instance_of Hubspot::Contact }
        its(:utk){ should == 'f844d2217850188692f2610c717c2e9b' }
      end

      context 'when the contact cannot be found' do
        it 'raises an error' do
          expect { Hubspot::Contact.find_by_utk('invalid') }.to raise_error(Hubspot::RequestError)
        end
      end
    end

    context 'batch mode' do
      cassette 'contact_find_by_utk_batch_mode'

      it 'find lists of contacts' do
        utks = ['f844d2217850188692f2610c717c2e9b', 'j94344d22178501692f2610c717c2e9b']
        expect { Hubspot::Contact.find_by_utk(utks) }.to raise_error(Hubspot::ApiError)
      end
    end
  end

  describe '.search' do
    subject { Hubspot::Contact.search(query, options) }

    cassette 'contact_search'

    let(:options) { {} }

    context 'when query returns contacts' do
      let(:query) { '@hubspot.com' }

      it { expect(subject['has-more']).to eq(true) }
      it { subject['contacts'].each { |contact| expect(contact).to be_an_instance_of(Hubspot::Contact) } }

      context 'when query finds more than count, but is limited' do
        let(:options) { { count: 1 } }

        it { expect(subject['has-more']).to eq(true) }
        it { expect(subject['total'] > 1).to eq(true) }
      end
    end

    context 'when the query returns no results' do
      let(:query) { 'something_that_does_not_exist' }

      it { expect(subject['total']).to eq(0) }
      it { expect(subject['has-more']).to eq(false) }
      it { expect(subject['contacts']).to be_empty }
    end
  end

  describe '.all' do
    context 'all contacts' do
      cassette 'find_all_contacts'

      it 'must get the contacts list' do
        contacts = Hubspot::Contact.all

        expect(contacts.size).to eql 20 # default page size

        first = contacts.first
        last = contacts.last

        expect(first).to be_a Hubspot::Contact
        expect(first.vid).to eql 154835
        expect(first['firstname']).to eql 'HubSpot'
        expect(first['lastname']).to eql 'Test'

        expect(last).to be_a Hubspot::Contact
        expect(last.vid).to eql 196199
        expect(last['firstname']).to eql 'Eleanor'
        expect(last['lastname']).to eql 'Morgan'
      end

      it 'must get the contacts list with paging data' do
        contact_data = Hubspot::Contact.all({paged: true})
        contacts = contact_data['contacts']

        expect(contacts.size).to eql 20 # default page size

        first = contacts.first
        last = contacts.last

        expect(contact_data).to have_key 'vid-offset'
        expect(contact_data).to have_key 'has-more'

        expect(first).to be_a Hubspot::Contact
        expect(first.vid).to eql 154835
        expect(first['firstname']).to eql 'HubSpot'
        expect(first['lastname']).to eql 'Test'

        expect(last).to be_a Hubspot::Contact
        expect(last.vid).to eql 196199
        expect(last['firstname']).to eql 'Eleanor'
        expect(last['lastname']).to eql 'Morgan'
        expect(contact_data['has-more']).to eql true
        expect(contact_data['vid-offset']).to eql 196199
      end

      it 'must filter only 2 contacts' do
        contacts = Hubspot::Contact.all(count: 2)
        expect(contacts.size).to eql 2
      end

      it 'it must offset the contacts' do
        single_list = Hubspot::Contact.all(count: 1)
        expect(single_list.size).to eql 1
        first = single_list.first

        second = Hubspot::Contact.all(count: 1, vidOffset: first.vid).first
        expect(second.vid).to eql 196181
        expect(second['firstname']).to eql 'Charles'
        expect(second['lastname']).to eql 'Gowland'
      end
    end

    context 'recent contacts' do
      cassette 'find_all_recent_contacts'

      it 'must get the contacts list' do
        contacts = Hubspot::Contact.all(recent: true)
        expect(contacts.size).to eql 20

        first, last = contacts.first, contacts.last
        expect(first).to be_a Hubspot::Contact
        expect(first.vid).to eql 263794

        expect(last).to be_a Hubspot::Contact
        expect(last.vid).to eql 263776
      end
    end

    context 'recent created contacts' do
      cassette 'find_all_recent_created_contacts'

      it 'must get the contacts list' do
        contacts = Hubspot::Contact.all(recent_created: true)
        expect(contacts.size).to eql 20

        first, last = contacts.first, contacts.last
        expect(first).to be_a Hubspot::Contact
        expect(first.vid).to eql 5478174

        expect(last).to be_a Hubspot::Contact
        expect(last.vid).to eql 5476674
      end
    end
  end

  describe '.merge!' do
    cassette 'contact_merge'
    let(:primary_params) { { firstname: 'Hugh', lastname: 'Jackman' } }
    let(:primary_contact) { Hubspot::Contact.create!("primary_#{Time.now.to_i}@hsgem.com", primary_params) }
    let(:secondary_params) { { firstname: 'Wolverine' } }
    let(:secondary_contact) { Hubspot::Contact.create!("secondary_#{Time.now.to_i}@hsgem.com", secondary_params) }

    subject { Hubspot::Contact.merge!(primary_contact.vid, secondary_contact.vid) }

    it 'merges the contacts' do
      subject

      primary_find_by_id = Hubspot::Contact.find_by_id primary_contact.vid
      primary_find_by_email = Hubspot::Contact.find_by_email primary_contact.email
      secondary_find_by_id = Hubspot::Contact.find_by_id secondary_contact.vid
      secondary_find_by_email = Hubspot::Contact.find_by_email secondary_contact.email

      primary_find_by_id.email.should == primary_contact.email
      primary_find_by_id.email.should == primary_find_by_email.email
      primary_find_by_id.email.should == secondary_find_by_id.email
      primary_find_by_id.email.should == secondary_find_by_email.email
      primary_find_by_id['firstname'].should == 'Wolverine'
      primary_find_by_id['lastname'].should == 'Jackman'
    end
  end

  describe '#update!' do
    cassette 'contact_update'
    let(:contact){ Hubspot::Contact.new(example_contact_hash) }
    let(:params){ {firstname: 'Steve', lastname: 'Cunningham'} }
    subject{ contact.update!(params) }

    it{ should be_an_instance_of Hubspot::Contact }
    its(['firstname']){ should ==  'Steve' }
    its(['lastname']){ should ==  'Cunningham' }

    context 'when the request is not successful' do
      let(:contact){ Hubspot::Contact.new({'vid' => 'invalid', 'properties' => {}})}
      it 'raises an error' do
        expect{ subject }.to raise_error Hubspot::RequestError
      end
    end
  end

  describe '#destroy!' do
    cassette 'contact_destroy'
    let(:contact){ Hubspot::Contact.create!("newcontact_y_#{Time.now.to_i}@hsgem.com") }
    subject{ contact.destroy! }
    it { should be_true }
    it 'should be destroyed' do
      subject
      contact.destroyed?.should be_true
    end
    context 'when the request is not successful' do
      let(:contact){ Hubspot::Contact.new({'vid' => 'invalid', 'properties' => {}})}
      it 'raises an error' do
        expect{ subject }.to raise_error Hubspot::RequestError
        contact.destroyed?.should be_false
      end
    end
  end

  describe '#destroyed?' do
    let(:contact){ Hubspot::Contact.new(example_contact_hash) }
    subject{ contact }
    its(:destroyed?){ should be_false }
  end
end
