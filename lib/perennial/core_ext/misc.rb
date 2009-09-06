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
    
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end
    
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
  
  def underscore
    Inflector.underscore(self)
  end
  
  def camelize(capitalize_first_letter = true)
    Inflector.camelize(self, capitalize_first_letter)
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
  
  def stringify_keys!
    hash = {}
    self.each_pair { |k, v| hash[k.to_s] = v }
    replace hash
  end
  
  def stringify_keys
    hash = self.dup
    hash.stringify_keys!
    return hash
  end
  
end

class Module
  
  def has_libary(*items)
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