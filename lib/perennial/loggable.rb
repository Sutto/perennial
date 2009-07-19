module Perennial
  module Loggable
   
    def self.included(parent)
      parent.extend self
    end
    
    def logger
      Perennial::Logger
    end
    
  end
end