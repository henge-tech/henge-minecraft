require 'nbtfile'
require 'nbtfile-patch'
require 'yaml'

#
# http://minecraft.gamepedia.com/Region_file_format
#
class MCAFile

  attr_reader :locations
  attr_reader :timestamps
  attr_reader :chunks

  def initialize(io)
    @io = io
    @locations = []
    @timestamps = []
    @chunks = []
  end

  def load
    load_locations
    load_timestamps
    load_chunks
    self
  end

  def load_locations
    @io.seek(0)
    @locations = []
    1024.times do |i|
      @locations << {
        'index'  => i,
        'offset' => read_int(3),
        'count'  => read_int(1)
      }
    end
  end

  def load_timestamps
    @io.seek(4096)
    @timestamps = []
    1024.times do |i|
      @timestamps << read_int
    end
  end

  def load_chunks
    sector_size = 4096

    @io.seek(sector_size * 2)
    @chunks = []

    @locations.each.with_index do |loc, i|
      offset = loc['offset'] * sector_size
      @io.seek(offset)

      length = read_int
      compression_type = read_int(1)

      padding = sector_size - (length + 4) % sector_size
      padding = 0 if padding == sector_size

      # sector_count = (4 + length + padding) / sector_size.to_f
      # if sector_count != loc['count']
      #   puts "WARN #{i} #{offset} #{offset.to_s(16)} #{sector_count} #{loc['count']}"
      # end

      chunk_src = Zlib::Inflate.inflate(@io.read(length - 1))
      chunk_input = StringIO.new(chunk_src, 'rb:ascii-8bit')

      nbt = NBTFile.load_uncompressed(chunk_input)
      @chunks << nbt
    end
  end

  def read_int(len = 4)
    if len == 1
      ("\0" + @io.read(1)).unpack('n')[0]
    elsif len == 2
      @io.read(2).unpack('n')[0]
    elsif len == 3
      ("\0" + @io.read(3)).unpack('N')[0]
    else
      @io.read(4).unpack('N')[0]
    end
  end

  def self.load(io)
    self.new(io).load
  end

  def to_yaml
    data = {
      'locations' => @locations,
      'timestamps' => @timestamps,
      'chunks' => @chunks
    }
    YAML.dump(data)
  end
end
