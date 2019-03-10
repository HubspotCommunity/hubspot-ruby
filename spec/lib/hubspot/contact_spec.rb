RSpec.describe Hubspot::Contact do

  before{ Hubspot.configure(hapikey: 'demo') }

  describe '.find' do
    context 'with a valid ID' do
      cassette

      let(:company) { create :company }
      let(:contact) { create :contact, associatedcompanyid: company.id }
      subject { described_class.find contact.id }

      it 'finds the contact' do
        expect(subject).to be_a(described_class)
        expect(subject.id).to eq(contact.id)
      end
    end

    context 'with an invalid ID' do
      cassette

      subject { described_class.find 0 }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error(Hubspot::RequestError, /contact does not exist/)
      end
    end
  end

  describe '.create' do
    context 'without properties' do
      cassette

      let(:email) { Faker::Internet.safe_email("#{(0..3).map { (65 + rand(26)).chr }.join}#{Time.new.to_i.to_s[-5..-1]}") }
      subject { described_class.create email }

      it 'creates a new contact' do
        expect(subject).to be_a(described_class)
        expect(subject.id).not_to be_nil
      end
    end

    context 'with properties' do
      cassette

      let(:email) { Faker::Internet.safe_email("#{(0..3).map { (65 + rand(26)).chr }.join}#{Time.new.to_i.to_s[-5..-1]}") }
      let(:firstname) { "Allison" }
      let(:properties) { { firstname: firstname } }

      subject { described_class.create email, properties }

      it 'creates a new contact' do
        expect(subject).to be_a(described_class)
        expect(subject.id).not_to be_nil
      end

      it 'has the property set' do
        expect(subject.firstname).to eq(firstname)
      end

      it 'is persisted' do
        expect(subject).to be_persisted
      end
    end

    context 'with an existing email address' do
      cassette

      let(:contact) { create :contact }
      let(:email) { contact.email }

      subject { described_class.create email }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error(Hubspot::RequestError)
      end
    end

    context 'with an invalid email address' do
      cassette

      let(:email) { 'an_invalid_email' }

      subject { described_class.create email }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error(Hubspot::RequestError)
      end
    end
  end

  describe '.find_by_email' do
    cassette

    let(:contact) { create :contact }

    subject { described_class.find_by_email contact.email }

    it 'finds the contact' do
      expect(subject).to be_a(described_class)
      expect(subject.id).to eq(contact.id)
    end

    it 'is persisted' do
      expect(subject).to be_persisted
    end
  end

  describe '.find_by_user_token' do
    cassette

    let(:contact) { create :contact }
    subject { described_class.find_by_user_token contact.utk }

    it 'finds the contact' do
      skip 'need a contact with a user token'
      expect(subject).to be_a(described_class)
      expect(subject.id).to eq(contact.id)
    end
  end

  describe '.search' do
    cassette

    context 'when the query returns contacts' do
      subject { described_class.search 'com' }

      it 'has contacts' do
        expect(subject).not_to be_empty
        expect(subject.first).to be_a(described_class)
      end
    end

    context 'when the query returns no contacts' do
      subject { described_class.search '123xyz' }

      it 'has no contacts' do
        expect(subject).to be_empty
      end

      it 'does not have more' do
        expect(subject.more?).to be_falsey
      end

      it 'does not have a next page' do
        expect(subject.next_page?).to be_falsey
      end
    end
  end

  describe '.merge' do
    context 'with valid contact ids' do
      cassette

      let!(:contact1) { create :contact }
      let!(:contact2) { create :contact }

      subject { described_class.merge contact1.id, contact2.id }

      it 'succeeds' do
        expect(subject).to be_truthy
      end
    end

    context 'with invalid contact ids' do
      cassette

      subject { described_class.merge 1, 2 }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error(Hubspot::RequestError)
      end
    end
  end

  describe '#merge' do
    context 'with a valid contact' do
      cassette

      let!(:contact1) { create :contact }
      let!(:contact2) { create :contact }

      subject { contact1.merge(contact2) }

      it 'succeeds' do
        expect(subject).to be_truthy
      end
    end

    context 'with an invalid contact' do
      cassette

      let!(:contact1) { create :contact }

      subject { contact1.merge(1) }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error(Hubspot::RequestError)
      end
    end
  end
end
