require 'stringio'

class RBON
  VERSION = '0.0.210119'

  def initialize(newline:$/, tab:'  ')
    @rs, @tab = newline, tab
    @io = nil
  end

  def pretty_generate(object, io:StringIO.new)
    @io = io
    traverse(object,'')
    @io.print @rs
    @io.respond_to?(:string)? @io.string : nil
  end
  alias :dump :pretty_generate

  private

  def traverse(object, indent)
    case object
    when Hash
      hash(object, indent)
    when Array
      array(object, indent)
    when Symbol, String, Integer, Float, NilClass, TrueClass, FalseClass
      item(object, indent)
    else
      raise "Unsupported class #{object.class}: #{object.inspect}"
    end
  end

  def item(item, indent)
    case item
    when String
      @io.print item.lines.map{_1.inspect}.join(' +'+@rs+indent)
    else
      @io.print item.inspect
    end
  end

  def array(array, indent)
    if array.empty?
      @io.print '[]'
    else
      @io.print '['+@rs+indent+@tab
      traverse(array[0], indent+@tab)
      array[1..-1].each do |object|
        @io.print ','+@rs+indent+@tab
        traverse(object, indent+@tab)
      end
      @io.print @rs+indent+']'
    end
  end

  def hash(hash, indent)
    if hash.empty?
      @io.print '{}'
    else
      @io.print '{'+@rs+indent+@tab
      array = hash.to_a
      key_object(*array[0], indent+@tab)
      array[1..-1].each do |key,object|
        @io.print ','+@rs+indent+@tab
        key_object(key,object, indent+@tab)
      end
      @io.print @rs+indent+'}'
    end
  end

  def key_object(key, object, indent)
    raise "Bad Key #{key.class}: #{key.inspect}" unless key.is_a?(Symbol) and key.match?('^\w+[?!]?$')
    @io.print "#{key}: "
    traverse(object, indent)
  end
end
# Requires:
# `ruby`
