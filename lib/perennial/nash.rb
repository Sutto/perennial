require 'yaml'
module Perennial
  # A ninja hash. Like OpenStruct, but better
  class Nash
    
    def self.load_file(path)
      n = self.new
      if File.file?(path) && File.readable?(path)
        contents = YAML.load_file(path)
      end
      if contents.is_a?(Hash)
        contents.to_hash
      else
        new(:data => contents).normalized
      end
    end
    
    attr_reader :table
    
    def initialize(initial = {})
      @table = {}
      initial.to_hash.each_pair { |k,v| self[k] = v }
    end
    
    def [](key)
      @table[real_key(key)]
    end
    
    def []=(key, *values)
      @table.send(:[]=, real_key(key), *values)
    end
    
    def respond_to?(name, rec = nil)
      true
    end
    
    def id
      self.has_key?(:id) ? self.id : super
    end
    
    def dup
      Nash.new(self.table)
    end
    
    def to_hash
      @table.dup
    end
    
    def keys
      @table.keys
    end
    
    def values
      @table.values
    end
    
    def has_key?(key)
      @table.has_key? real_key(key)
    end
    
    def has_value?(value)
      @table.has_value? value
    end
    
    def each_pair
      @table.each_pair { |k, v| yield k, v }
    end
    
    def each_key
      @table.each_key { |k| yield k }
    end
    
    def each_value
      @table.each_value { |v| yield v }
    end
    
    def delete(key)
      @table.delete(real_key(key))
    end
    
    def merge!(hash_or_nash)
      hash_or_nash.to_hash.each_pair do |k, v|
        self[k] = v
      end
      return self
    end
    
    def merge(hash_or_nash)
      dup.merge! hash_or_nash
    end
    
    def reverse_merge!(hash_or_nash)
      replace Nash.new(hash_or_nash).merge!(self)
    end
    
    def reverse_merge(hash_or_nash)
      dup.reverse_merge(hash_or_nash)
    end
    
    def replace(nash)
      if nash.is_a?(self.class)
        @table = nash.table
      else
        @table = {}
        nash.to_hash.each_pair { |k, v| self[k] = v }
      end
      return self
    end
    
    def blank?
      @table.blank?
    end
    
    def present?
      @table.present?
    end
     
    def inspect
      str = ""
      if Thread.current[:inspect_stack].nil?
        Thread.current[:inspect_stack] = [self]
        str = _inspect
        Thread.current[:inspect_stack] = nil
      else
        if Thread.current[:inspect_stack].include?(self)
          return "..."
        else
          Thread.current[:inspect_stack] << self
          str = _inspect
          Thread.current[:inspect_stack].pop
        end
      end
      return str
    end
    
    def _inspect
      str = "#<Perennial::Nash:#{(object_id * 2).to_s(16)}"
      if !blank?
        str << " "
        str << table.map { |k, v| "#{k}=#{v.inspect}" }.join(", ")
      end
      str << ">"
      return str
    end
    
    def hash
      @table.hash
    end
    
    def normalized(n = nil)
      item = nil
      if Thread.current[:normalized].nil?
        n = self.class.new
        Thread.current[:normalized] = {self => n}
        item = normalize_nash(n)
        Thread.current[:normalized] = nil
      else
        if Thread.current[:normalized].has_key?(self)
          return Thread.current[:normalized][self]
        else
          n = self.class.new
          Thread.current[:normalized][self] = n
          item = normalize_nash(n)
        end
      end
      item
    end
     
    protected
    
    def normalize_nash(n = self.class.new)
      each_pair do |k, v|
        n[k] = normalize_item(v)
      end
      return n
    end
    
    def normalize_item(i)
      case i
      when Hash
        self.class.new(i).normalized
      when Array
        i.map { |v| normalize_item(v) }
      when self.class
        i.normalized
      else
        i
      end
    end
    
    def method_missing(name, *args, &blk)
      name = name.to_s
      case name.to_s[-1]
      when ??
        self[name[0..-2]].present?
      when ?=
        send(:[]=, real_key(name[0..-2]), *args)
      when ?!
        self[name[0..-2]] = self.class.new
      else
        self[name]
      end
    end
    
    def real_key(name)
      name.to_sym
    end
    
    
  end
end

class Hash
  def to_nash
    Perennial::Nash.new(self)
  end
end