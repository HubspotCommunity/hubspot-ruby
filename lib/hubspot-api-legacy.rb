require 'active_support'
require 'active_support/core_ext'
require 'httparty'
require 'hubspot_legacy/exceptions'
require 'hubspot_legacy/resource'
require 'hubspot_legacy/collection'
require 'hubspot_legacy/paged_collection'
require 'hubspot_legacy/properties'
require 'hubspot_legacy/company'
require 'hubspot_legacy/company_properties'
require 'hubspot_legacy/config'
require 'hubspot_legacy/connection'
require 'hubspot_legacy/contact'
require 'hubspot_legacy/contact_properties'
require 'hubspot_legacy/contact_list'
require 'hubspot_legacy/form'
require 'hubspot_legacy/blog'
require 'hubspot_legacy/topic'
require 'hubspot_legacy/deal'
require 'hubspot_legacy/deal_pipeline'
require 'hubspot_legacy/deal_properties'
require 'hubspot_legacy/deprecator'
require 'hubspot_legacy/owner'
require 'hubspot_legacy/engagement'
require 'hubspot_legacy/subscription'
require 'hubspot_legacy/oauth'

module HubspotLegacy
  def self.configure(config={})
    HubspotLegacy::Config.configure(config)
  end

  require 'hubspot_legacy/railtie' if defined?(Rails)
end

# Alias the module for those looking to use the stylized name HubSpot
HubSpotLegacy = HubspotLegacy
