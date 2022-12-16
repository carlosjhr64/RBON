require 'stringio'
module RBON
  VERSION = '0.2.221216'
  require 'rbon/dump'
  require 'rbon/load'

  # For simple String => Items conversions
  def self.load(...)
    Load.new.load(...)
  end

  # For simple Items => String conversions
  def self.dump(...)
    Dump.new.dump(...)
  end
end
# Requires:
# `ruby`
