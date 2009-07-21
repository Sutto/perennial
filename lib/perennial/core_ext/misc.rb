class Object

  def metaclass
    class << self; self; end
  end

end

class Inflector
  class << self

    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
    
  end
end

module Kernel
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
  
  def underscore
    Inflector.underscore(self)
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

class Hash
  def symbolize_keys
    hash = self.dup
    hash.symbolize_keys!
    return hash
  end
  
  def symbolize_keys!
    hash = {}
    self.each_pair { |k,v| hash[k.to_sym] = v }
    replace hash
  end
end