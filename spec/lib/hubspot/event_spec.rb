describe Hubspot::Event do
  let(:portal_id) { '62515' }
  let(:sent_portal_id) { portal_id }
  before { Hubspot.configure(hapikey: 'fake') }

  describe '.trigger' do
    let(:event_id) { '000000001625' }
    let(:email) { 'testingapis@hubspot.com' }
    let(:options) { {} }
    let(:base_url) { 'https://track.hubspot.com' }
    let(:url) { "#{base_url}/v1/event?_n=#{event_id}&_a=#{sent_portal_id}&email=#{CGI.escape email}" }
    subject { described_class.trigger(event_id, email, options) }

    it 'sends a request to trigger the event' do
      stub_request(:get, url)
        .to_return(status: 200)

      expect(subject).to be true
    end

    context 'with more options' do
      context 'with headers' do
        let(:headers) { Hash['User-Agent' => 'something'] }
        let(:options) { Hash[headers: headers] }

        it 'sends headers' do
          stub_request(:get, url)
            .with(headers: headers)
            .to_return(status: 200)

          expect(subject).to be true
        end
      end

      context 'when overriding portal_id' do
        let(:sent_portal_id) { '123' }
        let(:options) { { params: { _a: sent_portal_id } } }

        it 'sends a request to the portal_id in the options' do
          stub_request(:get, url)
            .with(headers: nil)
            .to_return(status: 200)

          expect(subject).to be true
        end
      end
    end
  end
end
