require 'corelib/enumerable'

class Struct
  include Enumerable

  def self.new(name = undefined, *args, &block)
    return super unless self == Struct

    if name[0] == name[0].upcase
      Struct.const_set(name, new(*args))
    else
      args.unshift name

      Class.new(self) {
        args.each { |arg| define_struct_attribute arg }

        instance_eval(&block) if block
      }
    end
  end

  def self.define_struct_attribute(name)
    if self == Struct
      raise ArgumentError, 'you cannot define attributes to the Struct class'
    end

    members << name

    attr_accessor name
  end

  def self.members
    if self == Struct
      raise ArgumentError, 'the Struct class has no members'
    end

    @members ||= []
  end

  def self.inherited(klass)
    members = @members

    klass.instance_eval {
      @members = members
    }
  end

  class << self
    alias [] new
  end

  def initialize(*args)
    members.each_with_index {|name, index|
      instance_variable_set "@#{name}", args[index]
    }
  end

  def members
    self.class.members
  end

  def [](name)
    if Integer === name
      raise IndexError, "offset #{name} too small for struct(size:#{members.size})" if name < -members.size
      raise IndexError, "offset #{name} too large for struct(size:#{members.size})" if name >= members.size

      name = members[name]
    elsif String === name
      raise NameError, "no member '#{name}' in struct" unless members.include?(name.to_sym)
    else
      raise TypeError, "no implicit conversion of #{name.class} into Integer"
    end

    instance_variable_get "@#{name}"
  end

  def []=(name, value)
    if Integer === name
      raise IndexError, "offset #{name} too small for struct(size:#{members.size})" if name < -members.size
      raise IndexError, "offset #{name} too large for struct(size:#{members.size})" if name >= members.size

      name = members[name]
    elsif String === name
      raise NameError, "no member '#{name}' in struct" unless members.include?(name.to_sym)
    else
      raise TypeError, "no implicit conversion of #{name.class} into Integer"
    end

    instance_variable_set "@#{name}", value
  end

  def each
    return enum_for(:each){self.size} unless block_given?

    members.each { |name| yield self[name] }
    self
  end

  def each_pair
    return enum_for(:each_pair){self.size} unless block_given?

    members.each { |name| yield name, self[name] }
    self
  end

  def eql?(other)
    hash == other.hash || other.each_with_index.all? {|object, index|
      self[members[index]] == object
    }
  end

  def length
    members.length
  end

  alias size length

  def to_a
    members.map { |name| self[name] }
  end

  alias values to_a

  def inspect
    result = "#<struct "

    if self.class == Struct
      result += "#{self.class} "
    end

    result += each_pair.map {|name, value|
      "#{name}=#{value.inspect}"
    }.join ", "

    result += ">"

    result
  end

  alias to_s inspect

  def to_h
    members.inject({}) {|h, name| h[name] = self[name]; h}
  end

  def values_at(*args)
    args = args.map{|arg| `arg.$$is_range ? #{arg.to_a} : arg`}.flatten
    %x{
      var result = [];
      for (var i = 0, len = args.length; i < len; i++) {
        if (!args[i].$$is_number) {
          #{raise TypeError, "no implicit conversion of #{`args[i]`.class} into Integer"}
        }
        result.push(#{self[`args[i]`]});
      }
      return result;
    }
  end
end
