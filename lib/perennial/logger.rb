module Perennial
  class Logger
    
    cattr_accessor :logger, :log_name
    
    @@log_name = "perennial.log"
    @@setup    = false
    
    class << self
      
      def setup?
        !!@@setup
      end
      
      def setup
        return if setup?
        setup!
      end
      
      def setup!
        log_path = Settings.root / "log" / @@log_name.to_str
        @@logger = new(log_path, Settings.log_level, Settings.verbose?)
        @@setup = true
      end
      
      def method_missing(name, *args, &blk)
       self.setup # Ensure the logger is setup
       @@logger.send(name, *args, &blk)
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
  
    LEVELS.each { |k,v| PREFIXES[k] = "[#{k.to_s.upcase}]".ljust 7 }

    COLOURS = {
      :fatal => 31, # red
      :error => 33, # yellow
      :warn  => 35, # magenta
      :info  => 32, # green
      :debug => 34  # white
    }
  
    attr_accessor :level, :file, :verbose
  
    def initialize(path, level = :info, verbose = false)
      @level   = level.to_sym
      @verbose = verbose
      @file    = File.open(path, "a+")
    end
  
    def close!
      @file.close
    end
  
    LEVELS.each do |name, value|
      define_method(name) do |message|
        write("#{PREFIXES[name]} #{message}", name) if LEVELS[@level] <= value
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
      !!@vebose
    end
  
    private
  
    def write(message, level = self.level)
      @file.puts message
      @file.flush
      $stdout.puts colourize(message, level) if verbose?
    end
  
    def colourize(message, level)
      "\033[1;#{COLOURS[level]}m#{message}\033[0m"
    end
 
    
  end
end