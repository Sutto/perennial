module Perennial
  
  # = Perennial::Dispatchable
  # A Generic mixin which lets you define an object
  # Which accepts handlers which can have arbitrary
  # events dispatched.
  # == Usage
  #
  #   class X
  #     include Perennial::Dispatchable
  #     self.handlers << SomeHandler.new
  #   end
  #   X.new.dispatch(:name, {:args => "Values"})
  #
  # Will first check if SomeHandler#handle_name exists,
  # calling handle_name({:args => "Values"}) if it does,
  # otherwise calling SomeHandler#handle(:name, {:args => "Values"})
  module Dispatchable
    
    def self.handler_mapping
      @@handler_mapping ||= Hash.new { |h,k| h[k] = [] }
    end
    
    def self.included(parent)
      parent.class_eval do
        include InstanceMethods
        extend  ClassMethods
      end
    end
    
    module InstanceMethods
      
      # Returns the handlers registered on this class,
      # used inside +dispatch+.
      def handlers
        self.class.handlers
      end
      
      def dispatch_queue
        @dispatch_queue ||= []
      end
      
      def dispatching?
        @dispatching ||= false
      end
      
      # Dispatch an 'event' with a given name to the handlers
      # registered on the current class. Used as a nicer way of defining
      # behaviours that should occur under a given set of circumstances.
      # == Params
      # +name+: The name of the current event
      # +opts+: an optional hash of options to pass
      def dispatch(name, opts = {})
        if !dispatching?
          Logger.debug "Dispatching #{name} event (#{dispatch_queue.size} queued - on #{self.class.name})"
          # Add ourselves to the queue
          @dispatching = true
          begin
            # The full handler name is the method we call given it exists.
            full_handler_name = :"handle_#{name.to_s.underscore}"
            # First, dispatch locally if the method is defined.
            self.send(full_handler_name, opts) if self.respond_to?(full_handler_name)
            # Iterate through all of the registered handlers,
            # If there is a method named handle_<event_name>
            # defined we sent that otherwise we call the handle
            # method on the handler. Note that the handle method
            # is the only required aspect of a handler. An improved
            # version of this would likely cache the respond_to?
            # call.
            self.handlers.each do |handler|
              if handler.respond_to?(full_handler_name)
                handler.send(full_handler_name, opts)
              else
                handler.handle name, opts
              end
            end
          # If we get the HaltHandlerProcessing exception, we
          # catch it and continue on our way. In essence, we
          # stop the dispatch of events to the next set of the
          # handlers.
          rescue HaltHandlerProcessing => e
            Logger.info "Halting processing chain"
          rescue Exception => e
            Logger.log_exception(e)
          end
          @dispatching = false
          dispatch(*@dispatch_queue.shift) unless dispatch_queue.empty?
        else
          Logger.debug "Adding #{name} event to the end of the queue (on #{self.class.name})"
          dispatch_queue << [name, opts]
        end
      end
      
    end
    
    module ClassMethods
      
      # Return an array of all registered handlers, ordered
      # by their class and then the order of insertion. Please
      # note that this will include ALL handlers up the inheritance
      # chain unless false is passed as the only argument.
      def handlers(recursive = true)
        handlers = []
        if recursive && superclass.respond_to?(:handlers)
          handlers += superclass.handlers(recursive)
        end
        handlers += Dispatchable.handler_mapping[self]
        return handlers
      end
      
      # Assigns a new array of handlers and assigns each - Note that
      # this will only set this classes handlers, it will not override
      # those for others above / below it in the inheritance chain.
      def handlers=(new_value)
        Dispatchable.handler_mapping.delete self
        [*new_value].each { |h| register_handler h }
      end
      
      # Appends a handler to the list of handlers for this object.
      # Handlers are called in the order they are registered.
      def register_handler(handler)
        unless handler.blank? || !handler.respond_to?(:handle)
          handler.registered = true if handler.respond_to?(:registered=)
          Dispatchable.handler_mapping[self] << handler 
        end
      end
      
    end
    
  end
end