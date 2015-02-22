describe Hubspot::Connection do
  before(:each) do
    @url = 'http://localhost:3000'
    @http_reponse = mock('http_response')
  end

  describe '.get_json' do 
  	it 'delegates url format to Hubspot::Utils, call HTTParty get and returns response' do 
  	  @http_reponse.success? { true }
      @http_reponse.parsed_response { {} }  
      
  	  mock(Hubspot::Utils).generate_url(@url, {}) { @url }
  	  mock(Hubspot::Connection).get(@url, format: :json) { @http_reponse }
      Hubspot::Connection.get_json(@url, {})
  	end
  end

  describe '.post_json' do 
  	it 'delegates url format to Hubspot::Utils, call HTTParty post and returns response' do 
  	  @http_reponse.success? { true }
      @http_reponse.parsed_response { {} }  
      
  	  mock(Hubspot::Utils).generate_url(@url, {}) { @url }
  	  mock(Hubspot::Connection).post(@url, body: "{}", headers: {"Content-Type"=>"application/json"}, format: :json) { @http_reponse }
      Hubspot::Connection.post_json(@url, params: {}, body: {})
  	end
  end

  describe '.delete_json' do 
  	it 'delegates url format to Hubspot::Utils, call HTTParty delete and returns response' do 
  	  @http_reponse.success? { true }

  	  mock(Hubspot::Utils).generate_url(@url, {}) { @url }
  	  mock(Hubspot::Connection).delete(@url, format: :json) { @http_reponse }
      Hubspot::Connection.delete_json(@url, {})
  	end
  end
end