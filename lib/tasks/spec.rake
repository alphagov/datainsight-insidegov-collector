unless [ENV["RACK_ENV"], ENV["RAILS_ENV"]].include?("production")
  require 'rspec/core/rake_task'
  require 'ci/reporter/rake/rspec'
  
  RSpec::Core::RakeTask.new do |task|
    task.pattern = 'spec/**/*_spec.rb'
  end
end
