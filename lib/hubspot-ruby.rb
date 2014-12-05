require 'active_support/core_ext'
require 'httparty'
require 'hubspot/exceptions'
require 'hubspot/config'
require 'hubspot/contact'
require 'hubspot/form'
require 'hubspot/blog'
require 'hubspot/topic'
require 'hubspot/deal'

module Hubspot
  def self.configure(config={})
    Hubspot::Config.configure(config)
  end
end
