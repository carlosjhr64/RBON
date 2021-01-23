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
  class EOL < Exception
    # End Of List
  end

  X = '\\'
  XX = X+X
  XQ = X+'"'
  XN = X+'n'

  NILS   = /^nil,?$/
  FALSES = /^false,?$/
  TRUES  = /^true,?$/

  INTEGER = /^\d+,?$/
  FLOAT   = /^\d+\.\d+,?$/

  KEY    = /^\w+[?!]?:/
  SYMBOL = /^:\w+[?!]?,?$/

  STRING  = /^".*",?$/
  STRINGS = /^".*"\s*[+]$/

  EMPTY_ARRAY = /^\[\],?$/
  OPEN_ARRAY  = '['
  CLOSE_ARRAY = /^\],?$/

  EMPTY_HASH = /^\{\},?$/
  OPEN_HASH  = '{'
  CLOSE_HASH = /^\},?$/

  def initialize
    @opened, @io = 0, nil
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
      @io = @io.lines.map(&:strip).reject{_1.start_with? '#'}
    when IO
      @io = @io.readlines.map(&:strip).reject{_1.start_with? '#'}
    else
      raise TypeError, "RBON#load: Need IO or String, got #{@io.class}."
    end
  end

  def build(items=nil)
    loop do
      item = get_item
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
  rescue EOL
    raise RBON::Load::Error unless @opened == 0
    return items
  end

  def chomp(string)
    string.chomp(',')[1..-2].gsub(XX,X).gsub(XQ,'"').gsub(XN,"\n")
  end

  def get_strings
    strings = ''
    while @io[0].match? STRINGS
      string = @io.shift
      strings << chomp(string.sub(/\s*[+]$/,''))
    end
    string = @io.shift
    raise RBON::Load::Error unless string.match? STRING
    strings << chomp(string)
    return strings
  end

  def get_item
    line = @io.shift or raise EOL
    case line
    when NILS
      nil
    when FALSES
      false
    when TRUES
      true
    when INTEGER
      line.to_i
    when FLOAT
      line.to_f
    when KEY
      key, string = line.split(/:\s*/,2)
      @io.unshift string
      item = get_item
      [key.to_sym, item]
    when SYMBOL
      then line[1..-1].chomp(',').to_sym
    when STRING
      chomp(line)
    when STRINGS
      @io.unshift line
      get_strings
    when EMPTY_ARRAY then []
    when OPEN_ARRAY
      @opened += 1
      build(Array.new)
    when CLOSE_ARRAY
      @opened -= 1
      raise CloseArray
    when EMPTY_HASH then {}
    when OPEN_HASH
      @opened += 1
      build(Hash.new)
    when CLOSE_HASH
      @opened -= 1
      raise CloseHash
    else
      raise RBON::Load::Error, "Unsupported Item: '#{line}'"
    end
  end
end
end
