class Hash
  def symbolize_keys
    hash = self.dup
    hash.symbolize_keys!
    return hash
  end
  
  def symbolize_keys!
    convert_keys_via :to_sym
  end
  
  def stringify_keys!
    convert_keys_via :to_s
  end
  
  def stringify_keys
    hash = self.dup
    hash.stringify_keys!
    return hash
  end
  
  protected
  
  def convert_keys_via(method)
    hash = {}
    self.each_pair { |k,v| hash[k.send(method)] = v }
    replace hash
  end
  
end