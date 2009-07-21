require 'yaml'

module Perennial
  # A simple
  class Settings
    
    cattr_accessor :configuration, :log_level, :verbose, :daemon, :root
                   
    @@verbose   = false
    @@log_level = :info
    @@daemon    = false
    
    class << self
      
      def daemon?
        !!@@daemon
      end
      
      def root
        @@root ||= File.expand_path(File.dirname(__FILE__) / ".." / ".."))
      end
      
      def setup?
        @@setup ||= false
      end
      
      def setup(options = {})
        self.setup!(options) unless setup?
      end
      
      def setup!(options = {})
        @@configuration = {}
        loaded_yaml = YAML.load_file(root / "config" / "settings.yml")
        loaded_options = loaded_yaml["default"].merge(options)
        @@configuration.merge!(loaded_options)
        @@configuration.symbolize_keys!
        # Generate a module 
        mod = generate_settings_accessor_mixin        
        extend  mod
        include mod
        @@setup = true
      end
      
      def [](key)
        self.setup
        return self.configuration[key.to_sym]
      end
      
      def []=(key, value)
        self.setup
        self.configuration[key.to_sym] = value
        return value
      end
      
      def to_hash
        self.configuration.dup
      end
      
      protected
      
      def generate_settings_accessor_mixin
        Module.new do
          Settings.configuration.keys.each do |k|
            define_method(k) do
              return Settings.configuration[k]
            end
            define_method("#{k}=") do |val|
              Settings.configuration[k] = val
            end
          end
        end
      end
      
    end

  end
end