require 'yaml'

module Perennial
  class Settings
    
    cattr_accessor :configuration, :log_level, :verbose, :daemon
                   
    @@verbose   = false
    @@log_level = :info
    @@daemon    = false
    
    class << self
      
      def daemon?
        !!@@daemon
      end
      
      def verbose?
        !!@@verbose
      end
      
      def root=(path)
        @@root = File.expand_path(path.to_str)
      end
      
      def root
        @@root ||= File.expand_path(File.dirname(__FILE__) / ".." / "..")
      end
      
      def library_root=(path)
        @@library_root = File.expand_path(path.to_str)
      end
      
      def library_root
        @@library_root ||= File.expand_path(File.dirname(__FILE__) / ".." / "..")
      end
      
      def setup?
        @@setup ||= false
      end
      
      def setup(options = {})
        self.setup!(options) unless setup?
      end
      
      def setup!(options = {})
        @@configuration = {}
        settings_file = root / "config" / "settings.yml"
        if File.exist?(settings_file)
          loaded_yaml = YAML.load(File.read(settings_file))
          @@configuration.merge! loaded_yaml["default"]
        end
        @@configuration.merge! options
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