require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core/rake_task'

desc 'Runs the RSpecs'
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ['--color']
end

task :default => :spec
