describe Hubspot::ContactProperties do
  describe '.add_default_parameters' do
    subject { Hubspot::ContactProperties.add_default_parameters({}) }
    context "default parameters" do
      its([:property]){ should == "email" }
    end
  end
end