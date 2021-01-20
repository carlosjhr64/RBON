module RBON
class Dump
  class Error < StandardError
  end

  def initialize(tab:'  ')
    @tab, @io = tab, nil
  end

  def dump(object, io:StringIO.new)
    @io = io
    traverse(object,'')
    @io.print "\n"
    @io.respond_to?(:string)? @io.string : nil
  end
  alias :pretty_generate :dump

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
      raise RBON::Dump::Error, "Unsupported class #{object.class}: #{object.inspect}"
    end
  end

  def item(item, indent)
    case item
    when String
      @io.print (item=='')?  '""' : item.lines.map{_1.inspect}.join(" +\n"+indent)
    else
      @io.print item.inspect
    end
  end

  def array(array, indent)
    if array.empty?
      @io.print '[]'
    else
      @io.print "[\n"+indent+@tab
      traverse(array[0], indent+@tab)
      array[1..-1].each do |object|
        @io.print ",\n"+indent+@tab
        traverse(object, indent+@tab)
      end
      @io.print "\n"+indent+']'
    end
  end

  def hash(hash, indent)
    if hash.empty?
      @io.print '{}'
    else
      @io.print "{\n"+indent+@tab
      array = hash.to_a
      key_object(*array[0], indent+@tab)
      array[1..-1].each do |key,object|
        @io.print ",\n"+indent+@tab
        key_object(key,object, indent+@tab)
      end
      @io.print "\n"+indent+'}'
    end
  end

  def key_object(key, object, indent)
    raise RBON::Dump::Error, "Bad Key #{key.class}: #{key.inspect}" unless key.is_a?(Symbol) and key.match?('^\w+[?!]?$')
    @io.print "#{key}: "
    traverse(object, indent)
  end
end
end
