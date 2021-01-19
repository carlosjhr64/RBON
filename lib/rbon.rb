require 'stringio'

class RBON
  VERSION = '0.0.210119'

  KEY     = /^\w+[?!]?:\s/
  SYMBOL  = /^:\w+[?!]?,?$/
  STRING  = /^".*",?$/
  INTEGER = /^\d+,?$/
  FLOAT   = /^\d+\.\d+$/

  EMPTY_ARRAY = /^\[\],?$/
  OPEN_ARRAY  = '['
  CLOSE_ARRAY = /^\],?$/

  EMPTY_HASH = /^\{\},?$/
  OPEN_HASH  = '{'
  CLOSE_HASH = /^\},?$/

  class Bug < Exception
  end
  class ParseError < StandardError
  end
  class CloseArray < Exception
  end
  class CloseHash < Exception
  end

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

  def load(io)
    @io = io
    readlines
    build
  end

  private

  def build(items=nil)
    while item = get_item
      case items
      when NilClass
        items = item
      when Array
        items.push item
      when Hash
        items[item[0]]=item[1]
      else
        raise Bug, "Unexpected Error"
      end
    end
    return items
  rescue CloseArray
    raise ParseError unless items.is_a? Array
    return items
  rescue CloseHash
    raise ParseError unless items.is_a? Hash
    return items
  end

  def get_item
    line = @io.shift or return nil
    case line
    when STRING
      line.chomp(',')[1..-2]
    when INTEGER
      line.to_i
    when FLOAT
      line.to_f
    when SYMBOL
      then line[1..-1].chomp(',').to_sym
    when KEY
      key, string = line.split(/\s+/,2)
      @io.unshift string
      item = get_item
      [key[0..-2].to_sym, item]
    when EMPTY_ARRAY then []
    when OPEN_ARRAY
      build(Array.new)
    when CLOSE_ARRAY
      raise CloseArray
    when EMPTY_HASH then {}
    when OPEN_HASH
      build(Hash.new)
    when CLOSE_HASH
      raise CloseHash
    else
      raise ParseError, "Unsupported Item: #{line}"
    end
  end

  def readlines
    case @io
    when String
      @io = @io.lines.map(&:strip)
    when IO
      @io = @io.readlines.map(&:strip)
    else
      raise "RBON#load: Need IO or String, got #{@io.class}."
    end
  end

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
