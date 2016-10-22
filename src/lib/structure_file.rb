require 'nbtfile'
require 'stringio'
require_relative 'nbtfile_patch'

class StructureFile
  include NBTFile
  attr_accessor :author

  def initialize(size)
    @version = 1
    @size = size
    @author = nil

    @blocks = []
    @palette = []
  end

  def nbt(obj)
    if obj.instance_of? ::Hash
      hash_to_compound(obj)
    elsif obj.instance_of? ::Array
      array_to_list(obj)
    elsif obj.instance_of? ::Fixnum
      Types::Int.new(obj)

      # :

    elsif obj.instance_of? ::String
      Types::String.new(obj)
    else
      obj
    end
  end

  def array_to_list(arr)
    list = arr.map {|o| nbt(o) }
    if list.empty?
      Types::List.new(Types::End, [])
    else
      Types::List.new(list[0].class, list)
    end
  end

  def hash_to_compound(hash)
    comp = {}
    hash.each { |k, v| comp[k] = nbt(v) }
    return Types::Compound.new(comp)
  end

  def add_palette(name, properties)
    palette = {
      'Name' => name,
      'Properties' => properties
    }
    @palette << palette
  end

  def palette=(palette)
    @palette = palette
  end

  def add_block(state, pos, nbt)
    block = {
      'state' => state,
      'pos' => pos,
      'nbt' => nbt
    }
    @blocks << block
  end

  def to_hash
    {
      'version' => @version,
      'author' => @author,
      'size' => @size,
      'palette' => @palette,
      'blocks' => @blocks,
    }
  end

  def write(out)
    io = StringIO.new()
    nbtobj = nbt(to_hash)
    NBTFile::write(io, '', nbtobj)
    io.seek(0)

    Zlib::GzipWriter.wrap(out) do |gz|
      gz.mtime = 1_470_000_000
      gz << io.read
    end
  end
end
