module Perennial
  # A mixin that provides logger instance and
  # class methods
  module Loggable
   
    def self.included(parent)
      parent.extend self
    end
    
    def logger
      Logger
    end
    
  end
end