require 'active_support'
require 'active_support/core_ext'
require 'httparty'
require 'hubspot/exceptions'
require 'hubspot/company'
require 'hubspot/config'
require 'hubspot/connection'
require 'hubspot/contact'
require 'hubspot/properties'
require 'hubspot/contact_properties'
require 'hubspot/contact_list'
require 'hubspot/form'
require 'hubspot/blog'
require 'hubspot/topic'
require 'hubspot/deal'
require 'hubspot/deal_properties'
require 'hubspot/owner'

module Hubspot
  def self.configure(config={})
    Hubspot::Config.configure(config)
  end
end
