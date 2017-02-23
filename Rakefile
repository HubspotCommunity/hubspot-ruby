# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:quick) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb'].select{ |s| !s.match("/live/") }
  end
  RSpec::Core::RakeTask.new(:live) do |spec|
    spec.pattern = FileList['spec/live/*_spec.rb']
  end
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hubspot-ruby #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Dir.glob('lib/tasks/*.rake').each { |r| load r }
