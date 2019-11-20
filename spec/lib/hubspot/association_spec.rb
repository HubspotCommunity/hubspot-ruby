RSpec.describe Hubspot::Association do
  before { Hubspot.configure(hapikey: 'demo') }

  describe '.create' do
    context 'with a valid ID' do
      cassette
      let(:company) { create :company }
      let(:contact) { create :contact }

      subject { described_class.create(company.id, contact.id, described_class::COMPANY_TO_CONTACT) }

      it 'associates the resources' do
        expect(subject).to be true
        expect(company.contact_ids.resources).to eq [contact.id]
      end
    end

    context 'with an invalid ID' do
      cassette
      let(:company) { create :company }
      subject { described_class.create(company.id, 1234, described_class::COMPANY_TO_CONTACT) }

      it 'raises an error' do
        expect { subject }.to raise_error(Hubspot::RequestError, /One or more associations are invalid/)
      end
    end
  end
end
