RSpec.describe Hubspot::Company do
  # let(:example_company_hash) do
  #   VCR.use_cassette("company_example") do
  #     HTTParty.get("https://api.hubapi.com/companies/v2/companies/21827084?hapikey=demo").parsed_response
  #   end
  # end
  # let(:company_with_contacts_hash) do
  #   VCR.use_cassette("company_with_contacts") do
  #     HTTParty.get("https://api.hubapi.com/companies/v2/companies/115200636?hapikey=demo").parsed_response
  #   end
  # end

  before{ Hubspot.configure(hapikey: "demo") }

  describe '.find' do
    context 'with a valid ID' do
      cassette
      let(:company) { create :company }
      subject { described_class.find company.id }

      it 'finds the company' do
        expect(subject).to be_a(described_class)
        expect(subject.id).to eq(company.id)
      end
    end

    context 'with an invalid ID' do
      cassette
      subject { described_class.find 0 }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error(Hubspot::RequestError, /resource not found/)
      end
    end
  end

  describe '.create' do
    context 'with no properties' do
      cassette
      subject { described_class.create }

      it 'creates a new company' do
        expect(subject).to be_a(described_class)
        expect(subject.id).not_to be_nil
      end
    end

    context 'with properties' do
      cassette

      let(:name) { "Foo Bar Inc." }
      let(:properties) { { name: name } }
      subject { described_class.create properties }

      it 'creates a new company' do
        expect(subject).to be_a(described_class)
        expect(subject.id).not_to be_nil
      end

      it 'has the property set' do
        expect(subject.name).to eq name
      end

      it 'is persisted' do
        expect(subject).to be_persisted
      end
    end
  end

  describe '.new' do
    context 'with no properties' do
      it 'returns a company' do
        expect(subject).to be_a(described_class)
      end

      it 'has no changes' do
        expect(subject.changes).to be_empty
      end

      it 'is not persisted' do
        expect(subject).not_to be_persisted
      end
    end

    context 'with properties' do
      subject { described_class.new name: Faker::Company.name }

      it 'has changes' do
        expect(subject.changed?).to be_truthy
      end

      it 'is not persisted' do
        expect(subject).not_to be_persisted
      end
    end

    context 'with an ID property' do
      subject { described_class.new id: 1 }

      it 'has changes' do
        pending "tracking ID property changes"
        expect(subject.changed?).to be_truthy
      end

      it 'is not persisted' do
        pending "persisted flag rework"
        expect(subject).not_to be_persisted
      end
    end
  end

  describe '#reload' do
    context 'with a valid ID' do
      cassette

      let(:company) { create :company }
      subject { inst = described_class.new(company.id); inst.reload }

      it 'loads the company details' do
        expect(subject.id).to eq(company.id)
        expect(subject.name).to eq(company.name)
      end
    end

    context 'without an ID' do
      cassette

      it 'raises an error' do
        expect {
          subject.reload
        }.to raise_error(Hubspot::InvalidParams)
      end
    end
  end

  describe '#save' do
    context 'with no changes' do
      cassette

      subject { described_class.new }

      it 'creates a new company' do
        expect {
          subject.save
        }.to change { subject.id }.from(nil)
      end

      it 'has no changes' do
        expect {
          subject
        }.not_to change { subject.changed? }.from(false)
      end
    end

    context 'with changes' do
      cassette

      subject { build :company }

      it 'persists the company' do
        expect {
          subject.save
        }.to change { subject.persisted? }.from(false).to(true)
      end

      it 'updates the ID property' do
        expect {
          subject.save
        }.to change { subject.id }.from(nil)
      end

      it 'resets the changes' do
        expect {
          subject.save
        }.to change { subject.changed? }.from(true).to(false)
      end
    end
  end

  describe '#delete' do
    context 'when not persisted' do
      cassette

      subject { build :company }

      it 'raises an error' do
        expect {
          subject.delete
        }.to raise_error(Hubspot::InvalidParams)
      end
    end

    context 'when persisted' do
      cassette

      subject { create :company }

      it 'sets the deleted flag' do
        expect {
          subject.delete
        }.to change { subject.deleted? }.from(false).to(true)
      end

      it 'deletes the resource' do
        subject.delete

        expect {
          described_class.find subject.id
        }.to raise_error(Hubspot::RequestError)
      end
    end
  end

  describe '.all' do
    context 'with no options' do
      cassette

      subject { described_class.all }

      it 'returns a collection' do
        expect(subject).to be_a(Hubspot::PagedCollection)
        expect(subject.first).to be_a(Hubspot::Company)
      end

      it 'has an offset' do
        expect(subject.next_offset).not_to be_blank
      end

      it 'identifies if there are more resources' do
        expect(subject.more?).not_to be_nil
      end
    end

    context 'with an offset' do
      cassette

      let!(:company) { create :company }
      subject { described_class.all offset: company.id }

      it 'returns a collection' do
        expect(subject).to be_a(Hubspot::PagedCollection)
      end

      it 'has an offset' do
        expect(subject.next_offset).not_to be_blank
      end

      it 'identifies if there are more resources' do
        expect(subject.more?).not_to be_nil
      end
    end

    context 'with a limit' do
      cassette

      let(:limit) { 1 }
      subject { described_class.all limit: limit }

      it 'returns a collection' do
        expect(subject).to be_a(Hubspot::PagedCollection)
        expect(subject.first).to be_a(Hubspot::Company)
      end

      it 'respects the limit' do
        expect(subject.size).to eq(limit)
      end
    end
  end

  describe '.search_domain' do
    cassette

    let!(:company) { create :company }

    subject { described_class.search_domain company.domain }

    it 'returns a collection' do
      expect(subject).to be_a(Hubspot::PagedCollection)
      expect(subject.first).to be_a(Hubspot::Company)
    end
  end

  describe '.recently_created' do
    cassette

    subject { described_class.recently_created }

    it 'returns a collection' do
      expect(subject).to be_a(Hubspot::PagedCollection)
    end
  end

  describe '.recently_modified' do
    cassette

    subject { described_class.recently_modified }

    it 'returns a collection' do
      expect(subject).to be_a(Hubspot::PagedCollection)
    end
  end

  describe '.add_contact' do
    context 'with a valid company ID and contact ID' do
      cassette

      let(:company) { create :company }
      let(:contact) { create :contact }

      subject { described_class.add_contact company.id, contact.id }

      it 'returns success' do
        expect(subject).to be_truthy
      end

      it 'adds the contact to the company' do
        expect {
          subject
        }.to change { company.contact_ids }.by([contact.id])
      end
    end

    context 'with a valid company ID and invalid contact ID' do
      cassette

      let(:company) { create :company }

      subject { described_class.add_contact company.id, 1 }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error(Hubspot::RequestError, /Contact with the vid/)
      end
    end

    context 'with an invalid company ID' do
      cassette

      subject { described_class.add_contact 1, 1 }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error(Hubspot::RequestError, /company with the ID/)
      end
    end
  end

  describe '.remove_contact' do
    context 'with a valid company ID and contact ID' do
      cassette allow_playback_repeats: true

      let!(:company) { create :company }
      let!(:contact) { create :contact, associatedCompanyId: company.id }

      subject { described_class.remove_contact company.id, contact.id }

      it 'returns success' do
        expect(subject).to be_truthy
      end

      # Testing this turns out to be hard since using associatedCompanyId doesn't immediately add
      # the contact to the company but triggers some background job to perform the update. Since
      # we're testing the gem interface and not the API (that's Hubspot's job) this should be OK to
      # leave out.
      #
      # it 'removes the contact from the company'
    end
  end
end
