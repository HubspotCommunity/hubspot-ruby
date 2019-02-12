module CassetteHelper
  def self.extended(base)
    base.around do |spec|
      VCR.insert_cassette(_cassette) if defined?(_cassette) && _cassette
      spec.run
      VCR.eject_cassette if defined?(_cassette) && _cassette
    end
  end

  def cassette(cassette_name = nil)
    let(:_cassette) do |example|
      cassette_name || example.full_description
    end
  end
end
