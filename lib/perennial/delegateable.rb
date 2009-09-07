module Perennial
  # Objective-C / Cocoa style 'delegates'.
  # Essentially proxies which dispatch only
  # when an object responds to the method.
  class DelegateProxy < Proxy
    
    def initialize(t)
      @__proxy_target__ = t
    end
    
    def respond_to?(method, inc_super = false)
      true
    end
    
    protected
    
    def method_missing(method, *args, &blk)
      @__proxy_target__.send(method, *args, &blk) if @__proxy_target__.respond_to?(method)
    end
    
  end
  
  module Delegateable
    
    def self.included(parent)
      parent.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
      
      def delegate=(value)
        @delegate = DelegateProxy.new(value)
      end
      
      alias delegate_to delegate=
      
      def delegate
        @delegate ||= DelegateProxy.new(nil)
      end
      
      def real_delegate
        @delegate && @delegate.__proxy_target__
      end
      
    end
    
  end
end