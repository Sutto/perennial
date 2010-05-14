module Perennial
  class Dispatcher
    
    cattr_accessor :dispatchable_mapping
    self.dispatchable_mapping ||= {}
    
    cattr_accessor :queue_constructor
    self.queue_constructor ||= proc { |key, object| [] }
    
    def initialize(object, key = nil)
      key ||= self.class.key_for_object(object)
      @queue = self.class.queue_constructor.call(key, object)
    end
    
    def self.create_queue(object, key = nil)
      key ||= key_for_object(object)
      queue = self.new(object, key)
      self.dispatchable_mapping[key] = queue
      queue
    end
    
    def self.dispatch(object_or_key, event, options = {})
    end
    
    def self.key_for_object(object, key = nil)
      key || (object.respond_to?(:to_dispatcher_key) ? object.to_dispatcher_key : :"#{object.class.name}:#{object.object_id}")
    end
    
  end
end