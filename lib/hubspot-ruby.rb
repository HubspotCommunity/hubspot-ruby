require 'active_support/core_ext'
require 'httparty'
require 'hubspot/exceptions'
require 'hubspot/config'
require 'hubspot/contact'
require 'hubspot/form'

module Hubspot
  def self.configure(config={})
    Hubspot::Config.configure(config)
  end
end