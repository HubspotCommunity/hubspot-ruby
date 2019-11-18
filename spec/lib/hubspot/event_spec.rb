describe Hubspot::Event do
  let(:portal_id) { '62515' }
  let(:sent_portal_id) { portal_id }
  before { Hubspot.configure(hapikey: 'demo', portal_id: portal_id) }

  describe '.trigger' do
    let(:event_id) { '000000001625' }
    let(:email) { 'testingapis@hubspot.com' }
    let(:options) { {} }
    let(:base_url) { 'https://track.hubspot.com' }
    let(:url) { "#{base_url}/v1/event?_n=#{event_id}&_a=#{sent_portal_id}&email=#{CGI.escape email}" }

    subject { described_class.trigger(event_id, email, options) }

    before { stub_request(:get, url).to_return(status: 200, body: JSON.generate({})) }

    it('sends a request to trigger the event') { is_expected.to be true }

    context 'with headers' do
      let(:headers) { { 'User-Agent' => 'something' } }
      let(:options) { { headers: headers } }

      it('sends headers') { is_expected.to be true }
    end

    context 'when overriding portal_id' do
      let(:sent_portal_id) { '123' }
      let(:options) { { params: { _a: sent_portal_id } } }

      it('sends a request to the portal_id in the options') { is_expected.to be true }
    end
  end
end
