# blank? parts taken from the active support source
# code, used under the MIT License.

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end

end
 
class NilClass #:nodoc:
  def blank?
    true
  end
end
 
class FalseClass #:nodoc:
  def blank?
    true
  end
end
 
class TrueClass #:nodoc:
  def blank?
    false
  end
end
 
class Array #:nodoc:
  alias_method :blank?, :empty?
end
 
class Hash #:nodoc:
  alias_method :blank?, :empty?
end
 
class String #:nodoc:
  def blank?
    self !~ /\S/
  end
end
 
class Numeric #:nodoc:
  def blank?
    false
  end
end