require 'rake'
require 'rake/testtask'

task :default => "test:units"

namespace :test do
  
  desc "Runs the unit tests for perennial"
  Rake::TestTask.new("units") do |t|
    t.pattern = 'test/*_test.rb'
    t.verbose = true
  end
  
end

task :gemspec do
  require 'rubygems'
  require File.join(File.dirname(__FILE__), "lib", "perennial")
  spec = Gem::Specification.new do |s|
    s.name        = 'perennial'
    s.email       = 'sutto@sutto.net'
    s.homepage    = 'http://sutto.net/'
    s.authors     = ["Darcy Laycock"]
    s.version     = Perennial::VERSION
    s.summary     = "A simple (generally event-oriented) application library for Ruby"
    s.description = "Perennial is a platform for building different applications in Ruby. It uses a controller-based approach with mixins to provide different functionality."
    s.files       = FileList["{bin,lib,templates}/**/*"].to_a
    s.executables = FileList["bin/*"].to_a.map { |f| File.basename(f) }
    s.platform    = Gem::Platform::RUBY
  end
  File.open("perennial.gemspec", "w+") { |f| f.puts spec.to_ruby }
end