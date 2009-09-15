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
      
      def yes?(question)
        result = Readline.readline("#{question.to_s.strip} (y/n) ")
        result.downcase[0] == ?y
      end
      
      def ask(question, default)
        result = Readline.readline("#{question.to_s.strip} (default: #{default}) ")
        result.blank? ? default : result
      end
      
      def ask_password(question)
        system "stty -echo" 
        line = Readline.readline("#{question.to_s.strip} ").strip
        system "stty echo"
        print "\n"
        return line
      end
      
      def die!(message)
        $stderr.puts message
        exit! 1
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
      @banners         = {}
    end
    
    def option(name, description = nil, opts = {})
      option_parser.add(name, description, opts) { |v| @command_options[name] = v }
    end
    
    def add_default_options!
      option_parser.add_defaults!
    end
    
    def generator!
      if defined?(Generator)
        self.command_env = Generator::CommandEnv
      end
    end
    
    def controller!(controller, description, opts = {})
      return unless defined?(Loader)
      add_default_options!
      option :kill, "Kill any runninng instances"
      controller_name = controller.to_s.underscore
      controller = controller.to_sym
      command_name = controller_name.gsub("_", "-")
      add("#{command_name} #{"[PATH]" if !opts[:skip_path]}".strip, description) do |*args|
        options = args.extract_options!
        path = File.expand_path(args[0] || ".")
        Settings.root = path
        if options.delete(:kill)
          attempt_showing_banner
          puts "Attempting to kill processess for #{command_name}"
          Daemon.kill_all(controller)
        else
          Loader.run!(controller, options)
        end
      end
    end
    
    
    
    def add(raw_command, description = nil, &blk)
      raise ArgumentError, "You must provide a block with an #{self.class.name}#add" if blk.nil?
      raise ArgumentError, "Your block must accept atleast one argument (a hash of options)" if blk.arity == 0
      command, _ = raw_command.split(" ", 2)
      @banners[command] = raw_command
      @commands[command]     = blk
      @descriptions[command] = description if description.present?
      # Add the default help message for a command
      option_parser.add(:help, "Show this message") { help_for(command) }
      @option_parsers[command] = option_parser
      @option_parser = nil
    end
    
    def execute(arguments)
      return usage if arguments.empty?
      arguments = arguments.dup
      command = arguments.shift
      if @commands.has_key?(command)
        execute_command(command, arguments)
      else
        show_error "Unknown command '#{command}', please try again."
        usage(true)
      end
    end
    
    def usage(skip_banner = false)
      attempt_showing_banner unless skip_banner
      puts "Usage:"
      max_width = @banners.values.map { |b| b.length }.max
      @commands.keys.sort.each do |command|
        next unless @descriptions.has_key?(command)
        formatted_command = "#{@banners[command]} [OPTIONS]".ljust(max_width + 10)
        command = "  %s - %s" % [formatted_command, @descriptions[command]]
        puts command
      end
      puts ""
      puts "Please note: you can pass -h / --help to any command for more specific help"
    end
    
    def help_for(command, skip_banner = false)
      attempt_showing_banner unless skip_banner
      puts @descriptions[command]
      puts ""
      puts "Usage: #{$0} #{@banners[command]} [options]"
      puts "Options:"
      puts pad_left(@option_parsers[command].summary)
      exit
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
    
    def attempt_showing_banner
      if banner.present?
        puts banner
        puts ""
      end
    end
    
    protected
    
    def execute_command(command, arguments)
      command_proc = @commands[command]
      args, opts = extract_arguments(command, arguments)
      if valid_arity?(command_proc, args)
        args << opts
        @command_env.execute(command_proc, args)
      else
        help_for(command, true)
      end
    end
    
    def extract_arguments(command, arguments)
      option_parser = @option_parsers[command]
      if option_parser.present?
        option_parser.parse(arguments)
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
        attempt_showing_banner
        show_error "You didn't provide the correct number of arguments (needed #{needed_count}, provided #{provided_count})"
      elsif needed_count < 0 && (-needed_count - 2) > provided_count
        show_error "You didn't provide enough arguments - a minimum of #{-needed_count} are needed."
      else
        return true
      end
      
    end
    
    def show_error(text)
      attempt_showing_banner
      text = "Error: #{text}".strip
      puts "--#{"-" * text.length}"
      puts " #{text} "
      puts "--#{"-" * text.length}"
      puts ""
    end
    
    def pad_left(text, spacing = 2)
      text.split("\n").map { |l| "#{" " * spacing}#{l}" }.join("\n")
    end
    
  end
end