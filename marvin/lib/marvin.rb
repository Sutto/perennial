$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'perennial'

module Marvin
  include Perennial
  
  VERSION = "0.0.1"
  
  manifest do |m, l|
    Settings.root = File.dirname(__FILE__)
    # Initialize your controllers, e.g:
    # l.register_controller :client, Marvin::Client
  end
  
end
