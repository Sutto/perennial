require 'singleton'
module Perennial
  class OptionParser
    include Singleton
    
    attr_reader :arguments
    
    def initialize
      @parsed_values = {}
      @arguments     = []
      @callbacks     = {}
      @descriptions  = {}
      @shortcuts     = {}
    end
    
    def add(name, description, opts = {}, &blk)
      name = name.to_sym
      @callbacks[name] = blk
      @descriptions[name] = description
      shortcut = opts.has_key?(:shortcut) ? opts[:shortcut] : generate_default_shortcut(name)
      @shortcuts[shortcut] = name unless shortcut.blank?
    end
    
    def summary
      output = []
      max_length = 0
      @callbacks.each_key do |name|
        shortcuts = []
        @shortcuts.each_pair { |k,v| shortcuts << k if v == name }
        text = "--#{name.to_s.gsub("_", "-")}"
        text << ", #{shortcuts.map { |sc| "-#{sc}" }.join(", ")}" unless shortcuts.empty?
        max_length = [text.size, max_length].max
        output << [text, @descriptions[name]]
      end
      output.map { |text, description| "#{text}: ".ljust(max_length + 2) + description }.join("\n")
    end
    
    def parse(arguments = ARGV)
      arguments, options = ArgumentParser.parse(arguments)
      @arguments = arguments
      options.each_pair do |name, value|
        name = name.gsub("-", "_")
        expanded_name = @shortcuts[name] || name.to_sym
        callback = @callbacks[expanded_name]
        callback.call(value) if callback.present?
      end
      return nil
    end
    
    def self.method_missing(name, *args, &blk)
      self.instance.send(name, *args, &blk)
    end
    
    # Over ride with your apps custom banner
    def self.print_banner
    end
    
    def add_defaults!
      return if defined?(@defaults_added) && @defaults_added
      logger_levels = Logger::LEVELS.keys.map { |k| k.to_s }
      add(:daemon, 'Runs this application as a daemon') { Settings.daemon = true }
      add(:verbose, 'Runs this application verbosely, writing to STDOUT') { Settings.verbose = true }
      add(:log_level, "Sets this applications log level, one of: #{logger_levels.join(", ")}") do |level|
        if logger_levels.include?(level)
          Settings.log_level = level.to_sym
        else
          puts "The provided log level must be one of #{logger_levels.join(", ")} (Given #{level})"
          exit!
        end
      end
      add(:help, "Shows this help message") do
        self.print_banner
        $stdout.puts "Usage: #{$0} [options]"
        $stdout.puts "\nOptions:"
        $stdout.puts self.summary
        exit!
      end
      @defaults_added = true
    end
    
    def setup
      return if defined?(@setup) && @setup
      setup!
      @setup = true
    end
    
    def self.setup!
      opts = self.instance
      opts.add_defaults!
      opts.parse
      ARGV.replace opts.arguments
    end
    
    protected
    
    def generate_default_shortcut(name)
      raw = name.to_s[0, 1]
      if !@shortcuts.has_key?(raw)
        return raw
      elsif !@shortcuts.has_key?(raw.upcase)
        return raw.upcase
      else
        raise "No shortcut option could generate for '#{name}' - Please specify :short (possibly as nil) to override"
      end
    end
    
  end
end