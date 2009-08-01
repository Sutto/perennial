module Perennial
  # = Perennial::Hookable
  # 
  # Perennial::Hookable provides a generic set of functionality
  # for implementing simple block-based hooks / callbacks. On
  # a class level, this makes it easy for you to do event driven
  # programming in that code can be registered to be run
  # when something happens.
  #
  # Hookable differs from Perennial::Dispatchable in that it is
  # designed to be lightweight / used for things like setting things
  # up without all of the overhead of defining handlers / dispatching
  # messages.
  module Hookable
    
    def self.included(parent)
      parent.class_eval do
        extend ClassMethods
        cattr_accessor :hooks
        self.hooks = Hash.new { |h,k| h[k] = [] }
      end
    end
    
    module ClassMethods
      
      # Append a hook for a given type of hook in order
      # to be called later on via invoke_hooks!
      def append_hook(type, &blk)
        self.hooks_for(type) << blk unless blk.blank?
      end

      # Return all of the existing hooks or an empty
      # for a given hook type.
      def hooks_for(type)
        self.hooks[type.to_sym]
      end

      # Invoke (call) all of the hooks for a given
      # type.
      def invoke_hooks!(type)
        hooks_for(type).each { |hook| hook.call }
      end
      
      # Defines a set of handy methods to make it
      # easy to define simplistic block based hooks
      # on an arbitrary class.
      def define_hook(*args)
        klass = self.metaclass
        args.map { |a| a.to_sym }.each do |name|
          
          klass.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
            def #{name}(&blk)               # def before_run(&blk)
              append_hook(:#{name}, &blk)   #   append_hook(:before_run, &blk)
            end                             # end
          RUBY
          
        end
      end
      
    end
    
  end
end