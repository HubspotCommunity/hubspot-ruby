module CassetteHelper
  def self.extended(base)
    base.around do |spec|
      VCR.insert_cassette(_cassette, _cassette_options) if defined?(_cassette) && _cassette
      spec.run
      VCR.eject_cassette if defined?(_cassette) && _cassette
    end
  end

  def cassette(*args)
    options = args.extract_options!

    let(:_cassette) do |example|
      args.first || example.full_description
    end

    let(:_cassette_options) { options }
  end
end
