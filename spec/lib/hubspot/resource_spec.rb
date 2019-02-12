
RSpec.describe Hubspot::Resource do
  describe '#new' do
    context 'when specifying an ID' do
      let(:id) { 1 }
      subject { described_class.new(id) }

      it 'sets the id property' do
        expect(subject.id).to eq id
      end

      it "isn't persisted" do
        pending "rework of pending flag"
        expect(subject).not_to be_persisted
      end

      it 'has no changes' do
        expect(subject).not_to be_changed
      end
    end

    context 'when specifying properties' do
      let(:name) { Faker::Company.name }
      let(:properties) { { name: name } }
      subject { described_class.new properties }

      it 'has no id' do
        expect(subject.id).to be_nil
      end

      it 'has the property set' do
        pending "rework of initialize and from_result"
        expect(subject[:name]).to eq name
        expect(subject.name).to eq name
      end
    end
  end
end