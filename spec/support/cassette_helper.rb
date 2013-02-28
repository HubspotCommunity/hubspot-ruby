module CassetteHelper
  def self.extended(base)
    base.around do |spec|
      VCR.insert_cassette(_cassette, record: :new_episodes) if defined?(_cassette) && _cassette
      spec.run
      VCR.eject_cassette if defined?(_cassette) && _cassette
    end
  end

  def cassette(cassette_name)
    let(:_cassette){ cassette_name }
  end
end