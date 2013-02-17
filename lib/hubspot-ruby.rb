require 'active_support/core_ext'
require 'httparty'
require 'hubspot/config'
require 'hubspot/contact'

module Hubspot
  def self.configure(config={})
    Hubspot::Config.configure(config)
  end
end