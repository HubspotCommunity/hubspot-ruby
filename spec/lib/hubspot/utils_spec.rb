describe Hubspot::Utils do
  describe ".properties_to_hash" do
    let(:properties) do
      {
        "email" => {"value" => "email@address.com"},
        "firstname" => {"value" => "Bob"},
        "lastname" => {"value" => "Smith"}
      }
    end
    subject{ Hubspot::Utils.properties_to_hash(properties) }
    its(["email"]){ should == "email@address.com" }
    its(["firstname"]){ should == "Bob" }
    its(["lastname"]){ should == "Smith" }
  end

  describe ".hash_to_properties" do
    let(:hash) do
      {
        "email" => "email@address.com",
        "firstname" => "Bob",
        "lastname" => "Smith"
      }
    end
    subject{ Hubspot::Utils.hash_to_properties(hash) }
    it{ should be_an_instance_of Array }
    its(:length){ should == 3 }
    it{ should include({"property" => "email", "value" => "email@address.com"}) }
    it{ should include({"property" => "firstname", "value" => "Bob"}) }
    it{ should include({"property" => "lastname", "value" => "Smith"}) }
  end
end
