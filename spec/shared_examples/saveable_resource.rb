RSpec.shared_examples_for "a saveable resource" do |factory_name|
  describe '#save' do
    context 'with a new resource' do
      cassette
      let(:resource) { build factory_name }
      subject { resource.save }

      it 'succeeds' do
        expect(subject).to be_truthy
      end

      it 'sets the ID' do
        expect {
          subject
        }.to change { resource.id }.from(nil)
      end

      it 'clears the changes' do
        expect {
          subject
        }.to change { resource.changed? }.from(true).to(false)
      end
    end

    context 'with an existing resource' do
      cassette
      let(:resource) { create factory_name }
      subject { resource.save }

      before(:each) do
        set_property(resource)
      end

      it 'succeeds' do
        expect(subject).to be_truthy
      end

      it 'clears the changes' do
        expect {
          subject
        }.to change { resource.changed? }.from(true).to(false)
      end
    end
  end
end