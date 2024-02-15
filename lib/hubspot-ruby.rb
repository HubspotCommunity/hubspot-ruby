require 'active_support'
require 'active_support/core_ext'
require 'httparty'
require 'hubspot/exceptions'
require 'hubspot/properties'
require 'hubspot/company'
require 'hubspot/company_properties'
require 'hubspot/config'
require 'hubspot/connection'
require 'hubspot/contact'
require 'hubspot/contact_properties'
require 'hubspot/contact_list'
require 'hubspot/form'
require 'hubspot/blog'
require 'hubspot/topic'
require 'hubspot/deal'
require 'hubspot/deal_pipeline'
require 'hubspot/deal_properties'
require 'hubspot/owner'
require 'hubspot/engagement'
require 'hubspot/subscription'

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end
end

deprecation_message = <<~DEPRECATION_MESSAGE
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !!!! This fork of hubspot-ruby is deprecated. Please use the official hubspot-ruby   !!!! 
  !!!! gem or consider the hubspot-api-client gem.                                     !!!!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
DEPRECATION_MESSAGE

warn(deprecation_message.red)

module Hubspot
  def self.configure(config={})
    Hubspot::Config.configure(config)
  end

  require 'hubspot/railtie' if defined?(Rails)
end
