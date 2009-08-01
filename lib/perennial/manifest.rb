module Perennial
  class Manifest
    
    class_inheritable_accessor :app_name, :namespace
    self.app_name  = :perennial
    self.namespace =  Perennial
    
    def self.inspect
      "#<#{self.name} app_name: #{self.app_name.inspect}, namespace: #{self.namespace.inspect}>"
    end
    
    module Mixin
      # Called in your application to set the default
      # namespace and app_name. Also, if a block is
      # provided it yields first with Manifest and then
      # with the Loader class, making it simpler to setup.
      def manifest(&blk)
        Manifest.namespace = self
        Manifest.app_name  = self.name.to_s.underscore
        parent_folder = __DIR__(1)
        attempt_require parent_folder / 'core_ext', parent_folder / 'exceptions'
        unless blk.nil?
          args = []
          args << Manifest if blk.arity != 0
          args << Loader   if blk.arity > 1 || blk.arity < 0
          blk.call(*args)
        end
      end
    end
    
  end
end