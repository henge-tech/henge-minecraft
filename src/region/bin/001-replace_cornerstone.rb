#! /usr/bin/env ruby

# Read region files and add moss stones under the signes (#1)
#
# http://minecraft.gamepedia.com/Region_file_format
# http://minecraft.gamepedia.com/Chunk
# http://minecraft.gamepedia.com/Chunk_format

require 'yaml'
require 'stringio'
require 'awesome_print'
require 'nbtfile'

require_relative '../lib/nbtfile_patch'
require_relative '../lib/mcafile'

# mcafile > chunks(*1024 (32*32)) > Sections(*Y16) > Blocks (16*16*16)

def update_block(idx, chunk, offset, blocks, data)
  # the offset under the sign
  o = offset - 256

  b = blocks[o].unpack('C')[0]
  d = data[o / 2].unpack('C')[0]

  # http://minecraft.gamepedia.com/Chunk_format#Block_format
  #
  # Thus block[0] is byte[0] at 0x0F, block[1] is byte[0] at 0xF0,
  # block[2] is byte[1] at 0x0F, block[3] is byte[1] at 0xF0, etc. ...
  if o % 2 == 0
    d2    = d & 0x0f # This block data value (4bit)
    new_d = d & 0xf0 # New data byte (set 0)
  else
    d2    = d >> 4   # This block data value (4bit)
    new_d = d & 0x0f # New data byte (set 0)
  end

  puts "#{idx} #{chunk['Level']['xPos'].value} #{chunk['Level']['zPos'].value} #{o} #{b} #{d} #{d2}"

  blocks[o] = "\x30"
  data[o / 2] = [new_d].pack('C')
end

def update_mca(path)
  mcafile = MCAFile.new(path)
  mcafile.each_chunk do |idx, chunk_src|
    chunk = NBTFile.read(chunk_src)[1]
    changed = false
    chunk['Level']['Sections'].each.with_index do |section, section_y|
      next if section_y == 0
      bottom_section = chunk['Level']['Sections'].items[section_y - 1]

      blocks  = section['Blocks'].value
      data    = section['Data'].value

      bblocks = bottom_section['Blocks'].value
      bdata   = bottom_section['Data'].value

      blocks.each_char.with_index do |char, offset|
        next unless char == "\x3f"
        # puts "chunk:#{idx}\tY:#{section['Y'].value}\tblock:#{offset}"
        changed = true
        if offset < 256
          update_block(idx, chunk, offset, bblocks, bdata)
        else
          update_block(idx, chunk, offset, blocks, data)
        end
      end
    end

    if changed
      io = StringIO.new()
      NBTFile.write(io, '', chunk)
      io.seek(0)
      mcafile.write_chunk(idx, io.read)
    end
  end
end

def execute()
  mcafile = ARGV[0]
  if File.directory?(mcafile)
    regiondir = mcafile
    Dir.glob(File.join(regiondir, 'r.*.mca')) do |file|
      puts file
      update_mca(file)
    end
  else
    update_mca(mcafile)
  end
end

execute
