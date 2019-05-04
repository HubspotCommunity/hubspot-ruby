RSpec.shared_examples_for "an updateable resource" do |factory_name|
  describe '.update' do
    context 'with an existing resource' do
      cassette
      let(:resource) { create factory_name }
      subject { described_class.update(resource.id, changed_properties) }

      it 'succeeds' do
        expect(subject).to be_truthy
      end
    end

    context 'with an invalid resource' do
      cassette
      subject { described_class.update(0, changed_properties) }

      it 'fails' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '.update!' do
    context 'with an existing resource' do
      cassette
      let(:resource) { create factory_name }
      subject { described_class.update!(resource.id, changed_properties) }

      it 'succeeds' do
        expect(subject).to be_truthy
      end
    end

    context 'with an invalid resource' do
      cassette
      subject { described_class.update!(0, changed_properties) }

      it 'fails with an error' do
        expect {
          subject
        }.to raise_error Hubspot::RequestError
      end
    end
  end

  describe '#update' do
    context 'with no changes' do
      cassette
      let(:resource) { create factory_name }
      subject { resource.update(changed_properties) }

      it 'succeeds' do
        expect(subject).to be_truthy
      end

      it 'updates the properties' do
        subject
        changed_properties.each do |property, value|
          expect(resource.send(property.to_sym)).to eq value
        end
      end
    end

    context 'with overlapping changes' do
      cassette
      let(:resource) { create factory_name}
      subject { resource.update(changed_properties) }

      before(:each) do
        overlapping_properties.each do |property, value|
          resource.send("#{property}=".to_sym, value)
        end
      end

      it 'succeeds' do
        expect(subject).to be_truthy
      end

      it 'merges and updates the properties' do
        subject
        overlapping_properties.merge(changed_properties).each do |property, value|
          expect(resource.send(property.to_sym)).to eq value
        end
      end
    end
  end
end