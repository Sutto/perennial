module Perennial
  class Reloading
    include Perennial::Loggable
    
    cattr_accessor :mapping, :mtimes
    self.mapping = {}
    self.mtimes = {}
    
    def self.watch(file, relative_to = File.dirname(file))
      file = File.expand_path(file)
      raise ArgumentError, "You must provide the path to a file" unless File.file?(file)
      relative = file.gsub(/^#{File.expand_path(relative_to)}\//, '')
      name = relative.gsub(/\.rb$/, '').split("/").map { |part| part.camelize }.join("::")
      self.mapping[name] = file
      self.mtimes[file] = File.mtime(file)
    end
    
    def self.reload!
      self.mapping.each_pair do |constant, file|
        next unless File.mtime(file) > self.mtimes[file]
        begin
          # Get a relative name and namespace
          parts = constant.split("::")
          name = parts.pop
          ns = parts.inject(Object) { |a, c| a.const_get(c) }
          # Notify object pre-reload.
          final = ns.const_get(name)
          final.reloading! if final.respond_to?(:reloading!)
          final = nil
          # Remove the constant
          ns.send(:remove_const, name)
          load(file)
          # Notify the object it was reloaded...
          final = ns.const_get(name)
          final.reloaded! if final.respond_to?(:reloaded!)
          # Finally, update the mtime
          self.mtimes[file] = File.mtime(file)
        rescue Exception => e
          logger.fatal "Exception reloading #{file} (for #{constant})"
          Perennial::ExceptionTracker.log(e)
        end
      end
    end
    
  end
end