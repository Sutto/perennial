require 'open-uri'
require 'fileutils'

module Perennial
  class Generator
    
    attr_accessor :template_path, :destination_path
    
    def initialize(destination, opts = {})
      @destination_path = destination
      @template_path    = opts[:template_path] || File.join(Settings.library_path, "templates")
    end
    
    def download(from, to)
      file to, open(from).read
    end
    
    def folders(*args)
      args.each do |f|
        FileUtils.mkdir_p(expand_destination_path(f))
      end
    end
    
    def file(name, contents)
      folders File.dirname(name)
      File.open(expand_destination_path(name), "w+") do |f|
        f.write(contents)
      end
    end
    
    def template(source, destination, environment = {})
      
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
    
  end
end