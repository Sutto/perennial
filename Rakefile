# require 'rake'
# require 'rake/testtask'
# 
# PERENNIAL_MAIN_FILE = File.join(File.dirname(__FILE__), "lib", "perennial.rb")
# require PERENNIAL_MAIN_FILE
# 
# task :gemspec do
#   require 'rubygems'
#   require File.join(File.dirname(__FILE__), "lib", "perennial")
#   spec = Gem::Specification.new do |s|
#     s.name        = 'perennial'
#     s.email       = 'sutto@sutto.net'
#     s.homepage    = 'http://sutto.net/'
#     s.authors     = ["Darcy Laycock"]
#     s.version     = Perennial::VERSION
#     s.summary     = "A simple (generally event-oriented) application library for Ruby"
#     s.description = "Perennial is a platform for building different applications in Ruby. It uses a controller-based approach with mixins to provide different functionality."
#     s.files       = FileList["{bin,lib,templates}/**/*"].to_a
#     s.executables = FileList["bin/*"].to_a.map { |f| File.basename(f) }
#     s.platform    = Gem::Platform::RUBY
#   end
#   File.open("perennial.gemspec", "w+") { |f| f.puts spec.to_ruby }
# end

require 'rubygems'
require 'rake'

PERENNIAL_MAIN_FILE = File.join(File.dirname(__FILE__), "lib", "perennial.rb")
require PERENNIAL_MAIN_FILE

begin
  require 'jeweler'
  require 'perennial/jeweler_ext'
  Jeweler.versioning_via PERENNIAL_MAIN_FILE, Perennial::VERSION
  Jeweler::Tasks.new do |gem|
    gem.name        = "perennial"
    gem.summary     = "A simple (generally event-oriented) application library for Ruby"
    gem.description = "Perennial is a platform for building different applications in Ruby. It uses a controller-based approach with mixins to provide different functionality."
    gem.email       = 'sutto@sutto.net'
    gem.homepage    = 'http://sutto.net/'
    gem.authors     = ["Darcy Laycock"]
    gem.files       = FileList["{bin,lib,templates}/**/*"].to_a
    gem.executables = FileList["bin/*"].to_a.map { |f| File.basename(f) }
    gem.platform    = Gem::Platform::RUBY
    gem.add_development_dependency "thoughtbot-shoulda"
    gem.add_development_dependency "yard"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
