require 'zlib'

#
# http://minecraft.gamepedia.com/Region_file_format
#
class MCAFile
  SECTOR_BSIZE = 12
  SECTOR_SIZE = 4096

  CTYPE_GZIP = 1
  CTYPE_ZLIB = 2

  attr_reader :locations
  attr_reader :timestamps

  def initialize(file)
    @file = file
    @locations = []
    @timestamps = []
    @chunks = []

    init_tables unless File.exist?(file)

    load_headers
  end

  def init_tables
    File.open(@file, 'w') do |out|
      out << "\0".b * (SECTOR_SIZE * 2)
    end
  end

  def load_headers
    File.open(@file, 'rb:binary') do |io|
      load_locations(io)
      load_timestamps(io)
    end
  end

  def load_locations(io)
    io.seek(0)
    @locations = []

    io.read(SECTOR_SIZE).unpack('N*').each do |n|
      offset = n >> 8
      count = n & 0xff
      @locations << [offset, count]
    end
  end

  def load_timestamps(io)
    io.seek(SECTOR_SIZE)
    @timestamps = []
    io.read(SECTOR_SIZE).unpack('N*').each do |n|
      @timestamps << n
    end
  end

  def chunk(index, decompress = true)
    loc = @locations[index]
    return nil if loc[0] == 0

    File.open(@file, 'rb:binary') do |io|
      io.seek(loc[0] * SECTOR_SIZE)

      length = io.read(4).unpack('N')[0]
      ctype  = io.read(1).unpack('C')[0]
      chunk_src = io.read(length - 1)
      chunk_src = Zlib::Inflate.inflate(chunk_src) if decompress
      [length, ctype, chunk_src]
    end
  end

  # Find empty sector.
  #
  # @locations = [[2,2],[5,1],[9,5],[16,4], ...]
  #
  # --------------------
  # 01234567890123456789
  # LTXX.X...XXXXX..XXXX
  # --------------------
  #  L: location table
  #  T: timestamp table
  #  X: used sectors
  #  .: empty sectors
  #
  def find_writable_sector(sector_count)
    larger_count = 0x100
    larger_offset = nil
    last_offset = 2

    locs = @locations.sort { |a, b| a[0] <=> b[0] }
    1024.times do |i|
      next if locs[i][0] == 0
      gap = locs[i][0] - last_offset

      return last_offset if gap == sector_count

      if sector_count < gap && gap < larger_count
        larger_count = gap
        larger_offset = last_offset
      end

      last_offset = locs[i][0] + locs[i][1]
    end

    return larger_offset unless larger_offset.nil?

    # first chunk
    return 2 if locs.last[0] == 0

    # can't find an empty sector. return the end of sectors
    locs.last[0] + locs.last[1]
  end

  def empty_sectors
    empty_sectors = []
    last_offset = 2

    locs = @locations.map.sort { |a, b| a[0] <=> b[0] }
    1024.times do |i|
      next if locs[i][0] == 0
      gap = locs[i][0] - last_offset
      empty_sectors << [last_offset, gap] if gap > 0
      last_offset = locs[i][0] + locs[i][1]
    end
    end_offset = locs.last[0] + locs.last[1]
    [empty_sectors, end_offset]
  end

  def padding_size(len)
    size = SECTOR_SIZE - len % SECTOR_SIZE
    size = 0 if size == SECTOR_SIZE
    size
  end

  # @param timestamp nil: now, -1: do not change
  def delete_chunk(idx, timestamp = nil)
    fail ArgumentError, 'Bad index' if @locations[idx].nil?

    timestamp ||= Time.now.to_i

    File.open(@file, 'r+b:binary') do |io|
      write_location(io, idx, 0, 0)
      write_timestamp(io, idx, timestamp) if timestamp >= 0
    end
  end

  # @param timestamp nil: now, -1: do not change
  def write_chunk(idx, chunk_str, timestamp = nil, ctype = CTYPE_ZLIB)
    fail ArgumentError, 'Bad index' if @locations[idx].nil?

    timestamp ||= Time.now.to_i

    chunk_src = padded_chunk_src(ctype, chunk_str)
    sector_count = chunk_src.length >> SECTOR_BSIZE
    fail ArgumentError, 'Bad sector_count' if sector_count > 0xff

    (offset, moved) = writable_offset(@locations[idx], sector_count)

    File.open(@file, 'r+b:binary') do |io|
      write_location(io, idx, offset, sector_count) if moved
      write_timestamp(io, idx, timestamp) if timestamp >= 0

      io.seek(offset << SECTOR_BSIZE)
      io.write(chunk_src)
    end
  end

  def padded_chunk_src(ctype, chunk_str)
    if ctype == CTYPE_ZLIB
      chunk_src = Zlib::Deflate.deflate(chunk_str)
    elsif ctype == CTYPE_GZIP
      fail ArgumentError, 'Gzip compression type is not supported'
    else
      chunk_src = chunk_str
    end

    length = chunk_src.length + 1
    chunk_src = [length, CTYPE_ZLIB].pack('NC') + chunk_src
    chunk_src += "\0".b * padding_size(chunk_src.length)

    chunk_src
  end

  def writable_offset(current_loc, sector_count)
    moved = false

    if current_loc[1] >= sector_count
      # overwrite same sectors
      offset = current_loc[0]
      if current_loc[1] != sector_count
        current_loc[1] = sector_count
        moved = true
      end
    else
      offset = find_writable_sector(sector_count)
      moved = true
    end

    [offset, moved]
  end

  def write_location(io, idx, offset, sector_count)
    io.seek(idx * 4)
    io.write([offset << 8 | sector_count].pack('N'))
    @locations[idx] = [offset, sector_count]
  end

  def write_timestamp(io, idx, timestamp)
    io.seek(SECTOR_SIZE + idx * 4)
    io.write([timestamp].pack('N'))
    @timestamps[idx] = timestamp
  end

  def each_chunk
    1024.times do |i|
      loc = @locations[i]
      next if loc[0] == 0
      yield(i, chunk(i)[2])
    end
  end
end
