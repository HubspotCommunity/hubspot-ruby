describe Hubspot::Event do
  let(:portal_id) { '62515' }
  let(:sent_portal_id) { portal_id }
  before { Hubspot.configure(hapikey: 'demo', portal_id: portal_id) }

  describe '.complete' do
    let(:event_id) { '000000001625' }
    let(:email) { 'testingapis@hubspot.com' }
    let(:options) { {} }
    let(:base_url) { 'https://track.hubspot.com' }
    let(:url) { "#{base_url}/v1/event?_n=#{event_id}&_a=#{sent_portal_id}&email=#{CGI.escape email}" }
    let(:http_response) do
      mocked_response = mock('http_response')
      mocked_response.success? { true }
      mocked_response
    end
    subject { described_class.complete(event_id, email, options) }

    it 'sends a request to complete the event' do
      mock(Hubspot::EventConnection).get(url, body: nil, headers: nil) { http_response }
      expect(subject).to be true
    end

    context 'with more options' do
      context 'with headers' do
        let(:headers) { { 'User-Agent' => 'something' } }
        let(:options) { { headers: headers } }

        it 'sends headers' do
          mock(Hubspot::EventConnection).get(url, body: nil, headers: headers) { http_response }
          expect(subject).to be true
        end
      end

      context 'when overriding portal_id' do
        let(:sent_portal_id) { '123' }
        let(:options) { { params: { _a: sent_portal_id } } }

        it 'sends a request to the portal_id in the options' do
          mock(Hubspot::EventConnection).get(url, body: nil, headers: nil) { http_response }
          expect(subject).to be true
        end
      end
    end
  end
end
