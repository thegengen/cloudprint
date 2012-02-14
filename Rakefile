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
  gem.name = "cloudprint"
  gem.homepage = "http://github.com/minciue/cloudprint"
  #noinspection RubyResolve
  gem.license = "MIT"
  gem.summary = %Q{This library provides a ruby-esque interface to Google Cloud Print.}
  gem.description = %Q{This library provides a ruby-esque interface to Google Cloud Print.\ncloudprint is a work in progress. I'll be adding documentation once all the basic GCP functionality is supported.}
  gem.email = "eugen@lesseverything.com"
  #noinspection RubyResolve
  gem.authors = ["Eugen Minciu"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

#require 'rcov/rcovtask'
#Rcov::RcovTask.new do |test|
#  test.libs << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#  test.rcov_opts << '--exclude "gems/*"'
#end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cloudprint #{version}"
  #noinspection RubyResolve
  rdoc.rdoc_files.include('README*')
  #noinspection RubyResolve
  rdoc.rdoc_files.include('lib/**/*.rb')
end
