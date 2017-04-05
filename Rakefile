require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :build do
  system "gem build xcodebot.gemspec"
end

task :install do
  system "gem install xcodebot"
end

task :release => :build do
  system "gem push xcodebot-#{Xcodebot::VERSION}"
end
