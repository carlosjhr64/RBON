module RBON
class Load
  class Bug < Exception
  end
  class Error < StandardError
  end

  class CloseArray < Exception
  end
  class CloseHash < Exception
  end

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

  def initialize
    @io = nil
  end

  def load(io)
    @io = io
    readlines
    build
  end

  private

  def readlines
    case @io
    when String
      @io = @io.lines.map(&:strip)
    when IO
      @io = @io.readlines.map(&:strip)
    else
      raise TypeError, "RBON#load: Need IO or String, got #{@io.class}."
    end
  end

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
        raise RBON::Load::Bug, "Unexpected Error"
      end
    end
    return items
  rescue CloseArray
    raise RBON::Load::Error unless items.is_a? Array
    return items
  rescue CloseHash
    raise RBON::Load::Error unless items.is_a? Hash
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
      raise RBON::Load::Error, "Unsupported Item: #{line}"
    end
  end
end
end
