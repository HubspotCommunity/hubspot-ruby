require 'active_support/core_ext'
require 'httparty'
require 'hubspot/exceptions'
require 'hubspot/config'
require 'hubspot/property'
require 'hubspot/contact'
require 'hubspot/contact_property'
require 'hubspot/form'
require 'hubspot/blog'
require 'hubspot/topic'
require 'hubspot/deal'
require 'hubspot/deal_property'

module Hubspot
  def self.configure(config={})
    Hubspot::Config.configure(config)
  end
end
