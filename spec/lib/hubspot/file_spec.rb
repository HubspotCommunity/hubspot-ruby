describe Hubspot do

  let(:example_file_hash) do
    VCR.use_cassette("file_list", record: :none) do
      url = Hubspot::Connection.send(:generate_url, Hubspot::File::LIST_FILE_PATH)
      resp = HTTParty.get(url, format: :json)
      resp.parsed_response["objects"].first
    end
  end

  before do
    Hubspot.configure(hapikey: "demo")
  end

  describe Hubspot::File do

    describe ".find_by_id" do
      it "should fetch specific file" do
	VCR.use_cassette("file_find", record: :none) do
	  file = Hubspot::File.find_by_id(example_file_hash["id"])
	  file.id.should eq(example_file_hash["id"])
	end
      end
    end

    describe '#destroy!' do
      it 'should remove from hubspot' do
	VCR.use_cassette("file_delete", record: :none) do
          file = Hubspot::File.find_by_id(example_file_hash["id"])
	  res = file.destroy!
	  expect(res["succeeded"]).to be true
	end
      end
    end

  end

end
