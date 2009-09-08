# cattr_* and class_inheritable_* are taken from
# ActiveSupport. Included here to help keep the
# codebase simple / clean.

class Object
  
  unless respond_to?(:instance_variable_defined?)
    def instance_variable_defined?(variable)
      instance_variables.include?(variable.to_s)
    end
  end

  def instance_values #:nodoc:
    instance_variables.inject({}) do |values, name|
      values[name.to_s[1..-1]] = instance_variable_get(name)
      values
    end
  end

  if RUBY_VERSION >= '1.9'
    def instance_variable_names
      instance_variables.map { |var| var.to_s }
    end
  else
    alias_method :instance_variable_names, :instance_variables
  end
end

class Class
  def cattr_reader(*syms)
    syms.flatten.each do |sym|
      next if sym.is_a?(Hash)
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        unless defined? @@#{sym}  # unless defined? @@hair_colors
          @@#{sym} = nil          #   @@hair_colors = nil
        end                       # end
                                  #
        def self.#{sym}           # def self.hair_colors
          @@#{sym}                #   @@hair_colors
        end                       # end
                                  #
        def #{sym}                # def hair_colors
          @@#{sym}                #   @@hair_colors
        end                       # end
      EOS
    end
  end
 
  def cattr_writer(*syms)
    options = syms.extract_options!
    syms.flatten.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        unless defined? @@#{sym}                       # unless defined? @@hair_colors
          @@#{sym} = nil                               #   @@hair_colors = nil
        end                                            # end
                                                       #
        def self.#{sym}=(obj)                          # def self.hair_colors=(obj)
          @@#{sym} = obj                               #   @@hair_colors = obj
        end                                            # end
                                                       #
        #{"                                            #
        def #{sym}=(obj)                               # def hair_colors=(obj)
          @@#{sym} = obj                               #   @@hair_colors = obj
        end                                            # end
        " unless options[:instance_writer] == false }  # # instance writer above is generated unless options[:instance_writer] == false
      EOS
    end
  end
 
  def cattr_accessor(*syms)
    cattr_reader(*syms)
    cattr_writer(*syms)
  end
  
  # Defines class-level inheritable attribute reader. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[#to_s]> Array of attributes to define inheritable reader for.
  # @return <Array[#to_s]> Array of attributes converted into inheritable_readers.
  #
  # @api public
  #
  # @todo Do we want to block instance_reader via :instance_reader => false
  # @todo It would be preferable that we do something with a Hash passed in
  #   (error out or do the same as other methods above) instead of silently
  #   moving on). In particular, this makes the return value of this function
  #   less useful.
  def class_inheritable_reader(*ivars)
    instance_reader = ivars.pop[:reader] if ivars.last.is_a?(Hash)
 
    ivars.each do |ivar|
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{ivar}
          return @#{ivar} if self.object_id == #{self.object_id} || defined?(@#{ivar})
          ivar = superclass.#{ivar}
          return nil if ivar.nil? && !#{self}.instance_variable_defined?("@#{ivar}")
          @#{ivar} = ivar && !ivar.is_a?(Module) && !ivar.is_a?(Numeric) && !ivar.is_a?(TrueClass) && !ivar.is_a?(FalseClass) ? ivar.dup : ivar
        end
      RUBY
      unless instance_reader == false
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{ivar}
            self.class.#{ivar}
          end
        RUBY
      end
    end
  end
 
  # Defines class-level inheritable attribute writer. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[*#to_s, Hash{:instance_writer => Boolean}]> Array of attributes to
  #   define inheritable writer for.
  # @option syms :instance_writer<Boolean> if true, instance-level inheritable attribute writer is defined.
  # @return <Array[#to_s]> An Array of the attributes that were made into inheritable writers.
  #
  # @api public
  #
  # @todo We need a style for class_eval <<-HEREDOC. I'd like to make it
  #   class_eval(<<-RUBY, __FILE__, __LINE__), but we should codify it somewhere.
  def class_inheritable_writer(*ivars)
    instance_writer = ivars.pop[:writer] if ivars.last.is_a?(Hash)
    ivars.each do |ivar|
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{ivar}=(obj)
          @#{ivar} = obj
        end
      RUBY
      unless instance_writer == false
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{ivar}=(obj) self.class.#{ivar} = obj end
        RUBY
      end
 
      self.send("#{ivar}=", yield) if block_given?
    end
  end
 
  # Defines class-level inheritable attribute accessor. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[*#to_s, Hash{:instance_writer => Boolean}]> Array of attributes to
  #   define inheritable accessor for.
  # @option syms :instance_writer<Boolean> if true, instance-level inheritable attribute writer is defined.
  # @return <Array[#to_s]> An Array of attributes turned into inheritable accessors.
  #
  # @api public
  def class_inheritable_accessor(*syms, &block)
    class_inheritable_reader(*syms)
    class_inheritable_writer(*syms, &block)
  end
  
end