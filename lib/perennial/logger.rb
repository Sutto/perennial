require 'fileutils'

module Perennial
  class Logger
    
    cattr_accessor :logger, :log_name
    
    @@log_name            = "perennial.log"
    @@setup               = false
    @@default_logger_path = nil
    
    class << self
      
      def setup?
        !!@@setup
      end
      
      def setup
        return if setup?
        setup!
      end
      
      def default_logger_path=(value)
        @@default_logger_path = value
        # Rereun setup if setup is already done.
        setup! if setup?
      end
      
      def default_logger_path
        @@default_logger_path || (Settings.root / "log" / @@log_name.to_str)
      end
      
      def setup!
        @@logger = new(self.default_logger_path, Settings.log_level, Settings.verbose?)
        @@setup = true
      end
      
      def method_missing(name, *args, &blk)
       self.setup # Ensure the logger is setup
       @@logger.send(name, *args, &blk)
      end
      
      def warn(message)
        self.setup
        @@logger.warn(message)
      end
      
      def respond_to?(symbol, include_private = false)
        self.setup
        super(symbol, include_private) || @@logger.respond_to?(symbol, include_private)
      end
    
    end
    
    LEVELS = {
      :fatal => 7,
      :error => 6,
      :warn  => 4,
      :info  => 3,
      :debug => 0
    }
  
    PREFIXES = {}
  
    LEVELS.each { |k,v| PREFIXES[k] = "[#{k.to_s.upcase}]".rjust 7 }

    COLOURS = {
      :fatal => "red",
      :error => "yellow",
      :warn  => "magenta",
      :info  => "green",
      :debug => "blue"
    }
  
    attr_accessor :level, :file, :verbose
  
    def initialize(path, level = :info, verbose = Settings.verbose?)
      @level   = level.to_sym
      @verbose = verbose
      FileUtils.mkdir_p(File.dirname(path))
      @file    = File.open(path, "a+")
      @file.sync = true if @file.respond_to?(:sync=)
    end
  
    def close!
      @file.close
    end
  
    LEVELS.each do |name, value|
      define_method(name) do |message|
        write(message.to_s, name) if LEVELS[@level] <= value
      end
    
      define_method(:"#{name}?") do
        LEVELS[@level] <= value
      end
      
    end
  
    def log_exception(exception)
      error "Exception: #{exception}"
      exception.backtrace.each do |l|
        error ">> #{l}"
      end
    end
    
    def verbose?
      !!@verbose
    end
  
    private
  
    def write(message, level = self.level)
      c = COLOURS[level]
      message = ANSIFormatter.new("<f:#{c}>#{PREFIXES[level]}</f:#{c}> #{ANSIFormatter.clean(message)}")
      @file.puts   message.to_normal_s
      $stdout.puts message.to_formatted_s if verbose?
    end
 
    
  end
end