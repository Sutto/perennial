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
      describe "Initializing generator in #{destination}"
    end
    
    # Helpers for testing file state
    
    def fu
      FileUtils
    end
    
    def chmod(permissions, path)
      describe "Changing permissions for #{path} to #{permissions}"
      FileUtils.chmod(permissions, expand_destination_path(path))
    end
    
    def file?(path)
      describe "Checking if #{path} is a file"
      File.file?(expand_destination_path(path))
    end
    
    def executable?(path)
      describe "Checking if #{path} is an executable"
      File.executable?(expand_destination_path(path))
    end
    
    def directory?(path)
      describe "Checking if #{path} is a directory"
      File.directory?(expand_destination_path(path))
    end
    
    alias folder? directory?
    
    def exists?(path)
      describe "Checking if #{path} exists"
      File.exits?(expand_destination_path(path))
    end
    
    def download(from, to, append = false)
      describe "Downloading #{from}"
      file to, open(from).read, append
    end
    
    def folders(*args)
      args.each do |f|
        describe "Creating folder #{f}"
        FileUtils.mkdir_p(expand_destination_path(f))
      end
    end
    
    def file(name, contents, append = false)
      dest_folder = File.dirname(name)
      folders(dest_folder) unless File.directory?(expand_destination_path(dest_folder))
      describe "Creating file #{name}"
      File.open(expand_destination_path(name), "#{append ? "a" : "w"}+") do |f|
        f.write(contents)
      end
    end
    
    def template(source, destination, environment = {}, append = false)
      describe "Processing template #{source}"
      raw_template = File.read(expand_template_path(source))
      processed_template = ERB.new(raw_template).result(binding_for(environment))
      file destination, processed_template, append
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
      puts "[generator] #{action}"
    end
    
  end
end