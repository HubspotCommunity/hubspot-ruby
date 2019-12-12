require 'hubspot-api-ruby'
require 'rails'
module Hubspot
  class Railtie < Rails::Railtie
    rake_tasks do
      spec = Gem::Specification.find_by_name('hubspot-api-ruby')
      load "#{spec.gem_dir}/lib/tasks/hubspot.rake"
    end
  end
end
