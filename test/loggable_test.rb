require File.join(File.dirname(__FILE__), "test_helper")

class LoggableTest < Test::Unit::TestCase
  
  class ExampleLoggable
    include Perennial::Loggable
  end
  
  context "Defining a class as loggable" do
    
    setup do
      @example = ExampleLoggable.new
    end
    
    should 'define a logger instance method' do
      assert @example.respond_to?(:logger)
    end
    
    should 'define a logger class method' do
      assert ExampleLoggable.respond_to?(:logger)
    end
    
    should 'not define a logger= instance method' do
      assert !@example.respond_to?(:logger=)
    end
    
    should 'not define a logger= class method' do
      assert !ExampleLoggable.respond_to?(:logger=)
    end
    
    should 'define logger to be an instance of Perennial::Logger' do
      assert_equal Perennial::Logger, ExampleLoggable.logger
      assert_equal Perennial::Logger, @example.logger
    end
    
  end
  
end