
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
        expect(subject[:name]).to eq name
        expect(subject["name"]).to eq name
        expect(subject.name).to eq name
      end

      it 'has changes' do
        expect(subject.changes).not_to be_empty
      end
    end

    context 'with no arguments' do
      subject { described_class.new }

      it 'has no id' do
        expect(subject.id).to be_nil
      end

      it 'has no changes' do
        expect(subject).not_to be_changed
      end
    end
  end

  describe '#[]' do
    context 'using new' do
      let(:resource) { described_class.new(properties) }
      let(:properties) { { id: 1, firstname: 'John', lastname: 'Wayne' } }

      it { expect(resource[:firstname]).to eq 'John' }
      it { expect(resource['lastname']).to eq 'Wayne' }
      it { expect(resource[:middlename]).to be nil }
    end

    context 'using from_result' do
      let(:resource) { described_class.from_result({ properties: properties }) }
      let(:properties) { { id: { 'value' => 1 }, firstname: { 'value' => 'John' }, lastname: { 'value' => 'Wayne' } } }

      it { expect(resource[:firstname]).to eq 'John' }
      it { expect(resource['lastname']).to eq 'Wayne' }
      it { expect(resource[:middlename]).to be nil }
    end
  end

  describe '#adding_accessors' do
    describe 'getters' do
      context 'using new' do
        let(:resource) { described_class.new(properties) }
        let(:properties) { { id: 1, firstname: 'John', lastname: 'Wayne' } }

        it { expect(resource.firstname).to eq 'John' }
        it { expect(resource.lastname).to eq 'Wayne' }
      end

      context 'using from_result' do
        let(:resource) { described_class.from_result({ properties: properties }) }
        let(:properties) { { id: { 'value' => 1 }, firstname: { 'value' => 'John' }, lastname: { 'value' => 'Wayne' } } }

        it { expect(resource.firstname).to eq 'John' }
        it { expect(resource.lastname).to eq 'Wayne' }
      end
    end
  end
end
