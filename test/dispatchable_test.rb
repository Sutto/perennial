require File.join(File.dirname(__FILE__), "test_helper")

class DispatchableTest < Test::Unit::TestCase
  
  class ExampleDispatcher
    include Perennial::Dispatchable
  end
  
  class ExampleHandlerA
    
    attr_accessor :messages
    
    def initialize
      @messages = []
    end
    
    def handle(name, opts)
      @messages << [name, opts]
    end
    
  end

  class ExampleHandlerB < ExampleHandlerA; end
  
  context 'marking a class as dispatchable' do
    
    setup do
      @dispatcher = ExampleDispatcher.new
    end
    
    should 'define a dispatch method' do
      assert @dispatcher.respond_to?(:dispatch)
    end
    
    should 'require atleast a name for dispatch' do
      assert_equal -2, @dispatcher.method(:dispatch).arity
    end
    
  end
  
  context 'when registering handlers' do
    
    setup do
      @dispatcher = test_class_for(Perennial::Dispatchable)
    end
    
    should 'append a handler using register_handler' do
      assert_equal [], @dispatcher.handlers
      @dispatcher.register_handler(handler = ExampleHandlerA.new)
      assert_equal [handler], @dispatcher.handlers
    end
    
    should 'batch assign handlers on handlers= using register_handler' do
      handlers = [ExampleHandlerA.new, ExampleHandlerB.new]
      assert_equal [], @dispatcher.handlers
      @dispatcher.handlers = handlers
      assert_equal handlers, @dispatcher.handlers
    end
    
    should 'return all handlers via the handlers class method' do
      handlers = [ExampleHandlerA.new, ExampleHandlerB.new]
      @dispatcher.handlers = handlers
      assert_equal handlers, @dispatcher.handlers
    end
    
    should 'make handlers available to myself and all subclasses' do
      # Set A
      dispatcher_a = class_via(@dispatcher)
      dispatcher_a.register_handler(handler_a = ExampleHandlerA.new)
      # Set B
      dispatcher_b = class_via(dispatcher_a)
      dispatcher_b.register_handler(handler_b = ExampleHandlerA.new)
      # Set C
      dispatcher_c = class_via(dispatcher_b)
      dispatcher_c.register_handler(handler_c = ExampleHandlerA.new)
      # Set D
      dispatcher_d = class_via(dispatcher_a)
      dispatcher_d.register_handler(handler_d = ExampleHandlerB.new)
      # Actual Assertions
      assert_equal [],                                @dispatcher.handlers
      assert_equal [handler_a],                       dispatcher_a.handlers
      assert_equal [handler_a, handler_b],            dispatcher_b.handlers
      assert_equal [handler_a, handler_b, handler_c], dispatcher_c.handlers
      assert_equal [handler_a, handler_d],            dispatcher_d.handlers
    end
    
  end
  
  context 'dispatching events' do
    
    setup do
      @dispatcher = class_via(ExampleDispatcher).new
      @handler    = ExampleHandlerA.new
      @dispatcher.class.register_handler @handler
    end
    
    should 'attempt to call handle_[event_name] on itself' do
      mock(@dispatcher).respond_to?(:handle_sample_event) { true }
      mock(@dispatcher).handle_sample_event(:awesome => true, :sauce => 2)
      @dispatcher.dispatch :sample_event, :awesome => true, :sauce => 2
    end
    
    should 'attempt to call handle_[event_name] on each handler' do
      mock(@handler).respond_to?(:handle_sample_event) { true }
      mock(@handler).handle_sample_event(:awesome => true, :sauce => 2)
      @dispatcher.dispatch :sample_event, :awesome => true, :sauce => 2
    end
    
    should 'call handle on each handler if handle_[event_name] isn\'t defined' do
      mock(@handler).respond_to?(:handle_sample_event) { false }
      mock(@handler).handle(:sample_event, :awesome => true, :sauce => 2)
      @dispatcher.dispatch :sample_event, :awesome => true, :sauce => 2
    end
    
    should 'let you halt handler processing if you raise HaltHandlerProcessing' do
      handler_two = ExampleHandlerB.new
      @dispatcher.class.register_handler handler_two
      mock(@handler).handle(:sample_event, :awesome => true, :sauce => 2) do
        raise Perennial::HaltHandlerProcessing
      end
      dont_allow(handler_two).handle(:sample_event, :awesome => true, :sauce => 2)
      @dispatcher.dispatch :sample_event, :awesome => true, :sauce => 2
    end
    
    should 'log exceptions when encountered and not crash'
    
  end
  
end