RSpec.describe Hubspot::Association do
  before { Hubspot.configure(hapikey: 'demo') }

  let(:portal_id) { 62515 }
  let(:company) { create :company }
  let(:contact) { create :contact }

  describe '.create' do
    context 'with a valid ID' do
      cassette
      subject { described_class.create(company.id, contact.id, described_class::COMPANY_TO_CONTACT) }

      it 'associates the resources' do
        expect(subject).to be true
        expect(company.contact_ids.resources).to eq [contact.id]
      end
    end

    context 'with an invalid ID' do
      cassette
      subject { described_class.create(company.id, 1234, described_class::COMPANY_TO_CONTACT) }

      it 'raises an error' do
        expect { subject }.to raise_error(Hubspot::RequestError, /One or more associations are invalid/)
      end
    end
  end

  describe '.batch_create' do
    let(:deal) { Hubspot::Deal.create!(portal_id, [], [], {}) }

    subject { described_class.batch_create(associations) }

    context 'with a valid request' do
      cassette
      let(:associations) do
        [
          { from_id: deal.deal_id, to_id: contact.id, definition_id: described_class::DEAL_TO_CONTACT },
          { from_id: deal.deal_id, to_id: company.id, definition_id: described_class::DEAL_TO_COMPANY }
        ]
      end

      it 'associates the resources' do
        expect(subject).to be true
        find_deal = Hubspot::Deal.find(deal.deal_id)
        expect(find_deal.vids).to eq [contact.id]
        expect(find_deal.company_ids).to eq [company.id]
      end
    end

    context 'with an invalid ID' do
      cassette
      let(:associations) do
        [
          { from_id: deal.deal_id, to_id: 1234, definition_id: described_class::DEAL_TO_CONTACT },
          { from_id: deal.deal_id, to_id: company.id, definition_id: described_class::DEAL_TO_COMPANY }
        ]
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Hubspot::RequestError, /One or more associations are invalid/)
        find_deal = Hubspot::Deal.find(deal.deal_id)
        expect(find_deal.vids).to eq []
        expect(find_deal.company_ids).to eq []
      end
    end
  end

  describe '.delete' do
    subject { described_class.delete(company.id, contact_id_to_dissociate, described_class::COMPANY_TO_CONTACT) }
    before { described_class.create(company.id, contact.id, described_class::COMPANY_TO_CONTACT) }

    context 'with a valid ID' do
      cassette
      let(:contact_id_to_dissociate) { contact.id }

      it 'dissociates the resources' do
        expect(subject).to be true
        expect(company.contact_ids.resources).to eq []
      end
    end

    context 'with an invalid ID' do
      cassette
      let(:contact_id_to_dissociate) { 1234 }

      it 'does not raise an error' do
        expect(subject).to be true
        expect(company.contact_ids.resources).to eq [contact.id]
      end
    end
  end

  describe '.batch_delete' do
    let(:deal) { Hubspot::Deal.create!(portal_id, [company.id], [contact.id], {}) }

    subject { described_class.batch_delete(associations) }

    context 'with a valid request' do
      cassette
      let(:associations) do
        [
          { from_id: deal.deal_id, to_id: contact.id, definition_id: described_class::DEAL_TO_CONTACT },
          { from_id: deal.deal_id, to_id: company.id, definition_id: described_class::DEAL_TO_COMPANY }
        ]
      end

      it 'dissociates the resources' do
        expect(subject).to be true
        find_deal = Hubspot::Deal.find(deal.deal_id)
        expect(find_deal.vids).to eq []
        expect(find_deal.company_ids).to eq []
      end
    end

    context 'with an invalid ID' do
      cassette
      let(:associations) do
        [
          { from_id: deal.deal_id, to_id: 1234, definition_id: described_class::DEAL_TO_CONTACT },
          { from_id: deal.deal_id, to_id: company.id, definition_id: described_class::DEAL_TO_COMPANY }
        ]
      end

      it 'does not raise an error, removes the valid associations' do
        expect(subject).to be true
        find_deal = Hubspot::Deal.find(deal.deal_id)
        expect(find_deal.vids).to eq [contact.id]
        expect(find_deal.company_ids).to eq []
      end
    end
  end

  describe '.all' do
    subject { described_class.all(resource_id, definition_id) }

    context 'with valid params' do
      cassette

      let(:resource_id) { deal.deal_id }
      let(:definition_id) { described_class::DEAL_TO_CONTACT }
      let(:deal) { Hubspot::Deal.create!(portal_id, [], contact_ids, {}) }
      let(:contact_ids) { [contact.id, second_contact.id] }
      let(:second_contact) { create :contact }

      it 'finds the resources' do
        expect(subject.map(&:id)).to contain_exactly(*contact_ids)
      end
    end

    context 'with unsupported definition' do
      let(:resource_id) { 1234 }
      let(:definition_id) { -1 }

      it 'raises an error' do
        expect { subject }.to raise_error(Hubspot::InvalidParams, 'Definition not supported')
      end
    end
  end
end
