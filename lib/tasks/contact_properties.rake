require 'hubspot-ruby'

namespace :contact_properties do
  desc 'Dump contact properties to file'
  task :dump, [:file, :hapikey, :include, :exclude] do |_, args|
    hapikey = args[:hapikey] || ENV['HUBSPOT_API_KEY']
    props = Hubspot::Utils::dump_properties(hapikey, build_filter(args))
    if args[:file].blank?
      puts JSON.pretty_generate(props)
    else
      File.open(args[:file], 'w') do |f|
        f.write(JSON.pretty_generate(props))
      end
    end
  end

  desc 'Restore contact properties from file'
  task :restore, [:file, :hapikey, :dry_run] do |_, args|
    hapikey = args[:hapikey] || ENV['HUBSPOT_API_KEY']
    if args[:file].blank?
      raise ArgumentError, ':file is a required parameter'
    end
    file = File.read(args[:file])
    props = JSON.parse(file)
    Hubspot::Utils.restore_properties(hapikey, props, args[:dry_run])
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