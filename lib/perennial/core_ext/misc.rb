class Object

  def metaclass
    class << self; self; end
  end
  
  def meta_def(name, &blk)
    metaclass.define_method(name, &blk)
  end

end



module Kernel
  
  # From http://oldrcrs.rubypal.com/rcr/show/309
  def __DIR__(offset = 0)
    (/^(.+)?:\d+/ =~ caller[offset + 1]) ? File.dirname($1) : nil
  end
  
  # Shorthand for lambda
  # e.g. L{|r| puts r}
  def L(&blk)
    lambda(&blk)
  end
  
  # Shorthand for Proc.new
  # e.g. P{|r| puts r}
  def P(&blk)
    Proc.new(&blk)
  end
end

class String
  def /(*args)
    File.join(self, *args)
  end
  
  def to_pathname
    Pathname.new(self)
  end
end

class Array
  def extract_options!
    last.is_a?(Hash) ? pop : {}
  end
end

class Module
  
  def has_library(*items)
    namespace = self.to_s.underscore
    items.each do |item|
      require File.join(namespace, item.to_s.underscore)
    end
  end
  
  def extends_library(*items)
    namespace = self.to_s.underscore
    items.each do |item|
      klass = item.to_s.camelize.to_sym
      # Load if it isn't loaded already.
      const_get(klass) unless const_defined?(klass)
      # And finally load the file.
      require File.join(namespace, item.to_s.underscore)
    end 
  end
  
  def attempt_require(*files)
    files.each do |file|
      begin
        require file
      rescue LoadError
      end
    end
  end
  
end