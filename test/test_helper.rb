require 'rubygems'

# Testing dependencies
require 'test/unit'
require 'shoulda'
require 'rr'
require 'redgreen'

require 'pathname'
require Pathname.new(__FILE__).dirname.join("..", "lib", "perennial").expand_path

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end