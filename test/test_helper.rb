require 'rubygems'

# Testing dependencies
require 'test/unit'
require 'shoulda'
require 'rr'
# RedGreen doesn't seem to be needed under 1.9
require 'redgreen' if RUBY_VERSION < "1.9"

require 'pathname'
root_directory = Pathname.new(__FILE__).dirname.join("..").expand_path
require root_directory.join("lib", "perennial")
require root_directory.join("vendor", "fakefs", "lib", "fakefs")

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
  
  protected
  
  # Short hand for creating a class with
  # a given class_eval block.
  def class_via(*args, &blk)
    klass = Class.new(*args)
    klass.class_eval(&blk) unless blk.blank?
    return klass
  end
  
  # Short hand for creating a test class
  # for a set of mixins - give it the modules
  # and it will include them all.
  def test_class_for(*mods, &blk)
    klass = Class.new
    klass.class_eval { include(*mods) }
    klass.class_eval(&blk) unless blk.blank?
    return klass
  end
  
end