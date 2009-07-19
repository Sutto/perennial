# Append the perennial lib folder onto the load path to make it
# nicer to require perennial-related libraries.
$LOAD_PATH.unshift(File.dirname(__FILE__))

module Perennial
  
  autoload :Logger,   'perennial/logger'
  autoload :Loggable, 'perennial/loggable'
  
end