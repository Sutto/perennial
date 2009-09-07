module Perennial
  # a super simple proxy class.
  class Proxy
    
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }
    
    attr_accessor :__proxy_target__
    
    protected
    
    def method_missing(m, *args, &blk)
      __proxy_target__.send(m, *args, &blk)
    end
    
  end
end