module Perennial
  class Manifest
    
    cattr_accessor :manifest_mapping
    @@manifest_mapping = {}
    
    attr_accessor :app_name, :namespace
    
    def initialize(name, klass)
      self.app_name  = name
      self.namespace = klass
      @@manifest_mapping[klass.name] = self
    end
    
    def inspect
      "#<#{self.class.name} app_name: #{self.app_name.inspect}, namespace: #{self.namespace.inspect}>"
    end
    
    def self.[](klass)
      klass = klass.name if klass.respond_to?(:name)
      @@manifest_mapping[klass.split("::", 2).first]
    end
    
    def self.add_manifest(name, klass)
      self.new(name, klass)
    end
    
    add_manifest :perennial, Perennial
    
    module Mixin
      # Called in your application to set the default
      # namespace and app_name. Also, if a block is
      # provided it yields first with Manifest and then
      # with the Loader class, making it simpler to setup.
      def manifest(&blk)
        namespace = self
        app_name  = self.name.to_s.underscore
        manifest = Perennial::Manifest.add_manifest(app_name, namespace)
        parent_folder = File.expand_path(File.dirname(__DIR__(0)))
        Settings.library_root = parent_folder
        libary_folder = parent_folder / 'lib'/ app_name
        attempt_require((libary_folder / 'core_ext'), (libary_folder / 'exceptions'))
        unless blk.nil?
          args = []
          args << manifest if blk.arity != 0
          args << Loader   if blk.arity > 1 || blk.arity < 0
          blk.call(*args)
        end
      end
    end
    
  end
end