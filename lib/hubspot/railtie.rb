require 'hubspot-ruby'
require 'rails'
module HubSpot
  class Railtie < Rails::Railtie
    rake_tasks do
      spec = Gem::Specification.find_by_name('hubspot-ruby')
      import "#{spec.gem_dir}/lib/tasks/properties.rake"
    end
  end
end
