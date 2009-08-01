require 'shellwords'

module Perennial
  class ArgumentParser
    
    attr_reader :arguments
    
    def initialize(array)
      @raw_arguments = array.dup
      @arguments     = []
      @results       = {}
    end
    
    def to_hash
      @results ||= {}
    end
    
    def parse!
      while !@raw_arguments.empty?
        current = @raw_arguments.shift
        if option?(current)
          process_option(current, @raw_arguments.first) 
        else
          @arguments.push current
        end
      end
      return nil
    end
    
    def self.parse(args = ARGV)
      parser = self.new(args)
      parser.parse!
      return parser.arguments, parser.to_hash
    end
    
    protected
    
    def process_option(current, next_arg)
      name = clean(current)
      if name.include?("=")
        real_name, raw_value = name.split("=", 2)
        @results[real_name] = Shellwords.shellwords(raw_value).join(" ")
      elsif !(next_arg.nil? || option?(next_arg))
        @raw_arguments.shift
        @results[name] = next_arg
      else
        @results[name] = true
      end
    end
    
    def clean(name)
      name.gsub /^\-+/, ''
    end
    
    def option?(argument)
      argument.strip =~ /^\-+/
    end
    
  end
end