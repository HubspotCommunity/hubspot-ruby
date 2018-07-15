module Hubspot

  # Assuming that 2.0 will drop the old 'Hubspot' name
  #
  
  Deprecator = ActiveSupport::Deprecation.new( '2.0', 'hubspot-ruby')

  private

  def self.const_missing( class_name)
    Deprecator.deprecation_warning( "Hubspot::#{class_name}",
                                    "use HubSpot::#{class_name} instead")
    HubSpot.const_get( class_name)
  end

  def self.const_defined?( class_name, inherit = false)
    HubSpot.const_defined?( class_name, inherit)
  end
  
  def self.method_missing( method_name, *args, &block)
    class_name = ActiveSupport::Inflector.demodulize( name)

    if class_name == "Hubspot"
      Deprecator.deprecation_warning( "Hubspot.#{method_name}",
                                      "use HubSpot.#{method_name} instead")
      HubSpot.send( method_name, *args, &block)
    else
      Deprecator.deprecation_warning( "Hubspot::#{class_name}.#{method_name}",
                                      "use HubSpot::#{class_name}.#{method_name} instead")
      HubSpot.const_get( class_name).send( method_name, *args, &block)
    end
  end

  def self.respond_to_missing?( method_name, include_private = false)
    HubSpot.respond_to?( method_name, include_private)
  end
end
