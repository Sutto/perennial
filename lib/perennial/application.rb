module Perennial
  class Application
    
    class CommandEnv
      include Loggable
      
      # Executes a given block with given
      # arguments in a specified environment.
      # Used to provide the logger functionality
      # as well as the ability to do things
      # such as easily write generators.
      def self.execute(blk, arguments)
        klass = Class.new(self)
        klass.class_eval { define_method(:apply, &blk) }
        klass.new.apply(*arguments)
      end
      
    end
    
    attr_accessor :options, :banner, :command_env
    
    def initialize(opts = {})
      @options         = opts
      @commands        = {}
      @descriptions    = {}
      @option_parsers  = {}
      @option_parser   = nil
      @command_options = {}
      @command_env     = (opts[:command_env] || CommandEnv)
    end
    
    def option(name, description = nil)
      option_parser.add(name, description) { |v| @command_options[name] = v }
    end
    
    def add_default_options!
      option_parser.add_defaults!
    end
    
    def add(command, description = nil, &blk)
      raise ArgumentError, "You must provide a block with an #{self.class.name}#add" if blk.nil?
      raise ArgumentError, "Your block must accept atleast one argument (a hash of options)" if blk.arity == 0
      @commands[command]     = blk
      @descriptions[command] = description if description.present?
      unless @option_parser.nil?
        @option_parsers[command] = @option_parser
        @option_parser = nil
      end
    end
    
    def execute(arguments)
      return usage if arguments.empty?
      arguments = arguments.dup
      command = arguments.shift
      if @commands.has_key?(command)
        execute_command(command, arguments)
      else
        puts "Unknown command '#{command}', please try again."
        return usage
      end
    end
    
    def usage
      puts banner if banner.present?
    end
    
    def self.processing(args, &blk)
      application = self.new
      if blk.arity == 1
        blk.call(application)
      else
        application.instance_eval(&blk)
      end
      application.execute args
    end
    
    protected
    
    def execute_command(command, arguments)
      command = @commands[command]
      args, opts = extract_arguments(command, arguments)
      if valid_arity?(command, arguments)
        args << opts
        @command_env.execute(command, args)
      else
        usage
      end
    end
    
    def extract_arguments(command, arguments)
      option_parser = @option_parsers[command]
      if option_parser.present?
        option_parser.parse(ARGV)
        return option_parser.arguments, @command_options
      else
        return arguments, {}
      end
    end
    
    def option_parser(reset = false)
      @option_parser = nil if reset
      @option_parser ||= OptionParser.new
    end
    
    def valid_arity?(blk, arguments)
      needed_count   = blk.arity - 1
      provided_count = arguments.size
      if needed_count > 0 && needed_count != provided_count
        puts "You didn't provide the correct number of arguments (needed #{needed_count}, provided #{provided_count})"
      elsif needed_count < 0 && (-needed_count) > provided_count
        puts "You didn't provide enough arguments - a minimum of #{-needed_count} are needed."
      else
        return true
      end
      
    end
    
  end
end