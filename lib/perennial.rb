# Append the perennial lib folder onto the load path to make it
# nicer to require perennial-related libraries.
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pathname'
require 'perennial/core_ext'
require 'perennial/exceptions'

module Perennial
  
  autoload :Dispatchable, 'perennial/dispatchable'
  autoload :Logger,       'perennial/logger'
  autoload :Loggable,     'perennial/loggable'
  
end