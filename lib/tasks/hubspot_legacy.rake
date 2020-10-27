require 'hubspot-api-legacy'

namespace :hubspot_legacy do
  desc 'Dump properties to file'
  task :dump_properties, [:kind, :file, :hapikey, :include, :exclude] do |_, args|
    HubspotLegacy::Deprecator.build.deprecation_warning("hubspot_legacy:dump_properties")

    hapikey = args[:hapikey] || ENV['HUBSPOT_API_KEY']
    kind = args[:kind]
    unless %w(contact deal).include?(kind)
      raise ArgumentError, ':kind must be either "contact" or "deal"'
    end
    klass = kind == 'contact' ? HubspotLegacy::ContactProperties : HubspotLegacy::DealProperties
    props = HubspotLegacy::Utils::dump_properties(klass, hapikey, build_filter(args))
    if args[:file].blank?
      puts JSON.pretty_generate(props)
    else
      File.open(args[:file], 'w') do |f|
        f.write(JSON.pretty_generate(props))
      end
    end
  end

  desc 'Restore properties from file'
  task :restore_properties, [:kind, :file, :hapikey, :dry_run] do |_, args|
    HubspotLegacy::Deprecator.build.deprecation_warning("hubspot:restore_properties")

    hapikey = args[:hapikey] || ENV['HUBSPOT_API_KEY']
    if args[:file].blank?
      raise ArgumentError, ':file is a required parameter'
    end
    kind = args[:kind]
    unless %w(contact deal).include?(kind)
      raise ArgumentError, ':kind must be either "contact" or "deal"'
    end
    klass = kind == 'contact' ? HubspotLegacy::ContactProperties : HubspotLegacy::DealProperties
    file = File.read(args[:file])
    props = JSON.parse(file)
    HubspotLegacy::Utils.restore_properties(klass, hapikey, props, args[:dry_run] != 'false')
  end

  private

  def build_filter(args)
    { include: val_to_array(args[:include]),
      exclude: val_to_array(args[:exclude])
    }
  end

  def val_to_array(val)
    val.blank? ? val : val.split(/\W+/)
  end
end
