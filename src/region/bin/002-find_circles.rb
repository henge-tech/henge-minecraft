#! /usr/bin/env ruby

require 'yaml'
require 'awesome_print'
require 'nbtfile'

require_relative '../../lib/nbtfile_patch'
require_relative '../../lib/mcafile'

STDOUT.sync = true

#
# Find all 1st signs.
#

def find_first_sign(file)
  file =~ /r\.([^.]+)\.([^.]+)\.mca\z/
  region_x = $1.to_i
  region_z = $2.to_i

  mcafile = MCAFile.new(file)
  mcafile.each_chunk do |chunk_index, chunk_src|
    chunk = NBTFile.read(chunk_src)[1]

    tile_entities = chunk['Level']['TileEntities']
    signs = {}
    tile_entities.each do |te|
      if te['id'].value != 'Sign'
        # puts "# #{te['id'].value}"
        next
      end
      loc = "#{te['x'].value},#{te['z'].value},#{te['y'].value}"
      txt = te['Text2'].value.sub(/\A\{"text":"(.+)"\}\z/, '\1')
      signs[loc] = txt
    end

    chunk['Level']['Sections'].each.with_index do |section, section_y|
      blocks = section['Blocks'].value
      data   = section['Data'].value

      blocks.each_char.with_index do |char, offset|
        next unless char == "\x3f"
        d = MCAFile.halfbyte(data, offset)

        # http://minecraft.gamepedia.com/Sign
        #  0: south
        next if d != 0

        loc = MCAFile.block_to_mca(region_x, region_z, chunk_index, section_y, offset)

        word = signs["#{loc[:x]},#{loc[:z]},#{loc[:y]}"]
        puts "#{word}\t#{loc[:x]}\t#{loc[:y]}\t#{loc[:z]}"
      end
    end
  end
end

def execute()
  mcafile = ARGV[0]
  if File.directory?(mcafile)
    regiondir = mcafile
    Dir.glob(File.join(regiondir, 'r.*.mca')) do |file|
      puts "# #{file}"
      find_first_sign(file)
    end
  else
    find_first_sign(mcafile)
  end
end

execute
