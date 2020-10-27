module HubspotLegacyApiHelpers
  def hubspot_api_url(path)
    URI.join(HubspotLegacy::Config.base_url, path)
  end

  def assert_hubspot_api_request(method, path, options = {})
    assert_requested(method, /#{hubspot_api_url(path)}/, options)
  end
end

RSpec.configure do |c|
  c.include HubspotLegacyApiHelpers
end
