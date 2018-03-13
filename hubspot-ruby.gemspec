Gem::Specification.new do |s|
  s.name = "hubspot-ruby"
  s.version = "0.4.0"
  s.require_paths = ["lib"]
  s.authors = ["Andrew DiMichele", "Chris Bisnett"]
  s.description = "hubspot-ruby is a wrapper for the HubSpot REST API"
  s.files = [".rspec", "Gemfile", "Guardfile", "LICENSE.txt", "README.md", "RELEASING.md", "Rakefile", "hubspot-ruby.gemspec"]
  s.files += Dir["lib/**/*.rb"]
  s.files += Dir["lib/**/*.rake"]
  s.files += Dir["spec/**/*.rb"]
  s.homepage = "http://github.com/adimichele/hubspot-ruby"
  s.summary = "hubspot-ruby is a wrapper for the HubSpot REST API"

  # Add runtime dependencies here
  s.add_runtime_dependency "activesupport", ">=3.0.0"
  s.add_runtime_dependency "httparty", ">=0.10.0"

  # Add development-only dependencies here
  s.add_development_dependency("rake", "~> 11.0")
  s.add_development_dependency("rspec", "~> 2.0")
  s.add_development_dependency("rr")
  s.add_development_dependency("webmock", "< 1.10")
  s.add_development_dependency("vcr")
  s.add_development_dependency("rdoc")
  s.add_development_dependency("bundler")
  s.add_development_dependency("simplecov")
  s.add_development_dependency("awesome_print")
  s.add_development_dependency("timecop")
  s.add_development_dependency("guard-rspec")
end

