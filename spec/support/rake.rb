require "rake"

module RakeHelpers
  def invoke_rake_task(name, args = [])
    RakeTask.new(name).invoke(*args)
  end
end

class RakeTask
  def initialize(name)
    @task_name = name
    prep_environment
  end

  delegate :invoke, to: :task

  private

  attr_reader :task_name

  def prep_environment
    Rake.application = rake
    Rake.load_rakefile(full_task_path)
    Rake::Task.define_task(:environment)
  end

  def full_task_path
    "#{root_path}/lib/tasks/#{task_name.split(':').first}.rake"
  end

  def root_path
    File.expand_path('../..', __dir__)
  end

  def task
    rake[task_name]
  end

  def rake
    @_rake ||= Rake::Application.new
  end
end

RSpec.configure do |config|
  config.include RakeHelpers, type: :rake
end
