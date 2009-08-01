# Append the perennial lib folder onto the load path to make it
# nicer to require perennial-related libraries.
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pathname'
require 'perennial/core_ext'
require 'perennial/exceptions'

module Perennial
  
  autoload :Dispatchable, 'perennial/dispatchable'
  autoload :Hookable,     'perennial/hookable'
  autoload :Loader,       'perennial/loader'
  autoload :Logger,       'perennial/logger'
  autoload :Loggable,     'perennial/loggable'
  autoload :Manifest,     'perennial/manifest'
  autoload :Settings,     'perennial/settings'
  
  def self.included(parent)
    parent.extend Manifest::Mixin
  end
  
end