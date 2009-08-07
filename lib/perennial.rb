# Append the perennial lib folder onto the load path to make it
# nicer to require perennial-related libraries.
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pathname'
require 'perennial/core_ext'
require 'perennial/exceptions'

module Perennial
  
  VERSION = "0.1.0"
  
  has_libary :dispatchable, :hookable, :loader, :logger,
             :loggable, :manifest, :settings, :argument_parser,
             :option_parser, :application, :generator
  
  def self.included(parent)
    parent.extend(Manifest::Mixin)
  end
  
end