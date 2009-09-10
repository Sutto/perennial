require 'yaml'

module Perennial
  class Settings
    
    cattr_accessor :configuration, :log_level, :verbose, :daemon
  
    @@configuration         = Perennial::Nash.new
    @@verbose               = false
    @@log_level             = :info
    @@daemon                = false
    @@default_settings_path = nil
    @@lookup_key_path       = ["default"]
    
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
      
      def default_settings_path
        @@default_settings_path || (root / "config" / "settings.yml")
      end
      
      def default_settings_path=(value)
        @@default_settings_path = value
        setup! if setup?
      end
      
      def lookup_key_path
        @@lookup_key_path ||= []
      end
      
      def lookup_key_path=(value)
        @@lookup_key_path = value
      end
      
      def setup(options = {})
        self.setup!(options) unless setup?
      end
      
      def setup!(options = {})
        @@configuration ||= Perennial::Nash.new
        settings_file = self.default_settings_path
        if File.exist?(settings_file)
          loaded_yaml = YAML.load(File.read(settings_file))
          @@configuration.merge!(lookup_settings_from(loaded_yaml))
        end
        @@configuration.merge! options
        # Finally, normalize settings
        @@configuration = @@configuration.normalized
        @@setup = true
      end
      
      def update!(attributes = {})
        return if attributes.blank?
        settings_file = self.default_settings_path
        settings = File.exist?(settings_file) ? YAML.load(File.read(settings_file)) : {}
        namespaced_settings = lookup_settings_from(settings)
        namespaced_settings.merge! attributes.stringify_keys
        File.open(settings_file, "w+") { |f| f.write(settings.to_yaml) }
        setup!
        return true
      end
      
      def to_hash
        @@configuration.to_hash
      end
      
      def method_missing(name, *args, &blk)
        self.setup! unless self.setup?
        @@configuration.send(name, *args, &blk)
      end
      
      def respond_to?(name, rec = nil)
        true
      end
      
      protected
      
      def lookup_settings_from(settings_hash)
        lookup_key_path.inject(settings_hash) do |h, k|
          h[k.to_s] ||= {} 
        end
      end
      
    end
    
    def method_missing(name, *args, &blk)
      self.class.setup
      @@configuration.send(name, *args, &blk)
    end
    
    def respond_to?(name, rec = nil)
      true
    end

  end
end