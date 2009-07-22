require 'singleton'

module Perennial
  class Loader
    include Singleton
    include Perennial::Hookable
    
    cattr_accessor :controllers, :current_type, :default_type
    @@controllers = []
    
    define_hook :before_run, :after_stop
    
    def self.register_controller(name, controller)
      return if name.blank? || controller.blank?
      name = name.to_sym
      @@controller[name] = controller
      metaclass.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{name}?                 # def client?
          @@current_type == :#{name} #   @@current_type == :client
        end                          # end
      RUBY
    end
    
    def self.run!(type = self.default_type)
      @@current_type = type.to_sym
      self.instance.run!
    end
    
    def self.stop!(force = false)
      self.instance.stop!(force)
    end
    
    def run!
      self.register_signals
      self.class.invoke_hooks! :before_setup
      Daemon.daemonize! if Settings.daemon?
      Logger.log_name = "#{@@current_type.to_s}.log"
      Logger.setup
      Settings.setup
      self.load_custom_code
      self.class.invoke_hooks!        :before_run
      self.attempt_controller_action! :run
    end
    
    def stop!(force = false)
      if force || !@attempted_stop
        self.class.invoke_hooks!        :before_stop
        self.attempt_controller_action! :stop
        self.class.invoke_hooks!        :after_stop
        @attempted_stop = true
      end
      Daemon.cleanup! if Settings.daemon?
    end
    
    def current_controller
      @current_controller ||= @@controllers[@@current_type.to_sym]
    end
    
    protected
    
    def load_custom_code
      # Attempt to load a setup file given it exists.
      begin
        config_dir = Settings.root / "config"
        setup_file = config_dir / "setup.rb"
        require(setup_file) if File.directory?(handler_directory) && File.exist?(setup_file)
      rescue LoadError
      end
      # Load any existing handlers assuming we can find the folder
      handler_directory = Settings.root / "handlers"
      if File.directory?(handler_directory)
        Dir[handler_directory / "**" / "*.rb"].each do |handler|
          require handler
        end
      end
    end
    
    def register_signals
      loader = self.class
      %w(INT TERM).each do |signal|
        trap(signal) do
          loader.stop!
          exit
        end
      end
    end
    
    def attempt_controller_action!(action)
      action = action.to_sym
      unless current_controller.blank? || !current_controller.respond_to?(action)
        current_controller.send(action)
      end
    end
    
  end
end