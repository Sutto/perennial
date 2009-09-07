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