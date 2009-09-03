require 'open-uri'
require 'fileutils'
require 'erb'
require 'readline'

module Perennial
  class Generator
    
    class CommandEnv < Perennial::Application::CommandEnv
      
      def initialize
        @generator = nil
      end
      
      protected
      
      def setup_generator(*args)
        @generator = Generator.new(*args)
      end
      
      def method_missing(name, *args, &blk)
        if @generator && @generator.respond_to?(name)
          @generator.send(name, *args, &blk)
        else
          super
        end
      end
      
    end
    
    attr_accessor :template_path, :destination_path
    
    def initialize(destination, opts = {})
      @destination_path = destination
      @template_path    = opts[:template_path] || File.join(Settings.library_root, "templates")
      puts "Starting generator for #{destination}"
    end
    
    def download(from, to)
      describe "Downloading #{from}"
      file to, open(from).read
    end
    
    def folders(*args)
      args.each do |f|
        describe "Creating folder #{f}"
        FileUtils.mkdir_p(expand_destination_path(f))
      end
    end
    
    def file(name, contents)
      dest_folder = File.dirname(name)
      folders(dest_folder) unless File.directory?(expand_destination_path(dest_folder))
      describe "Creating file #{name}"
      File.open(expand_destination_path(name), "w+") do |f|
        f.write(contents)
      end
    end
    
    def template(source, destination, environment = {})
      describe "Processing template #{source}"
      raw_template = File.read(expand_template_path(source))
      processed_template = ERB.new(raw_template).result(binding_for(environment))
      file destination, processed_template
    end
    
    protected
    
    def binding_for(hash = {})
      object = Object.new
      hash.each_pair do |k, v|
        object.instance_variable_set("@#{k}", v)
      end
      return object.send(:binding)
    end
    
    def expand_template_path(p)
      File.expand_path(p, @template_path)
    end
    
    def expand_destination_path(p)
      File.expand_path(p, @destination_path)
    end
    
    def describe(action)
      puts "- #{action}"
    end
    
  end
end