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

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "jobber"
  gem.homepage = "http://github.com/dbldots/jobber"
  gem.executables = ["jobber-worker"]
  gem.license = "WTFPL"
  gem.summary = %Q{library for distributed jobs}
  gem.description = <<DESCRIPTION
jobber is a library that aims to provide a simple way to define distributed jobs.
works on top of mongoid, beanstalk and state_machine.
provides all the functionality to define jobs & run job workers.
DESCRIPTION
  gem.email = "dbldots@gmail.com"
  gem.authors = ["dbldots"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
