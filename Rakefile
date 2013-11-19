require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[-f JUnit -o pkg/results.xml]
end

task :default => :spec

