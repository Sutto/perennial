# Append the perennial lib folder onto the load path to make it
# nicer to require perennial-related libraries.
perennial_dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(perennial_dir) unless $LOAD_PATH.include?(perennial_dir)

require 'pathname'
require 'perennial/core_ext'
require 'perennial/exceptions'

module Perennial
  
  VERSION = "0.2.3.1"
  
  has_libary :dispatchable, :hookable, :loader, :logger,
             :loggable, :manifest, :settings, :argument_parser,
             :option_parser, :application, :generator, :daemon
  
  def self.included(parent)
    parent.extend(Manifest::Mixin)
  end
  
end