#! /usr/bin/env ruby

#
# Dig hole at front of the first sign.
#

require 'yaml'
require 'stringio'
require 'awesome_print'
require 'nbtfile'

require_relative '../../lib/nbtfile_patch'
require_relative '../../lib/mcafile'

STDOUT.sync = true

regions_dir = ARGV[0]

def execute(regions_dir)

  file = File.expand_path('../005-sort_and_add_id.log', __FILE__)

  mca_circles = {}
  open(file) do |f|
    f.each_line do |line|
      line.chomp!
      data = line.split(/\t/)
      circle = {}
      circle[:id] = data[0]
      xyz = data[1..3].map(&:to_i)
      circle[:pattern] = data[4]
      circle[:word] = data[5]

      loc  = MCAFile.coords_to_mca(xyz[0], xyz[2] + 1, xyz[1] - 1)

      # above 1, 2
      loc2 = MCAFile.coords_to_mca(xyz[0], xyz[2] + 1, xyz[1])
      loc3 = MCAFile.coords_to_mca(xyz[0], xyz[2] + 1, xyz[1] + 1)

      circle[:loc] = loc
      circle[:loc2] = loc2
      circle[:loc3] = loc3
      mca_circles[loc[:mcafile]] ||= []
      mca_circles[loc[:mcafile]] << circle
    end
  end

  mca_circles.each do |file, circles|
    # next if file != 'r.-1.0.mca'
    mcafile = MCAFile.new(File.join(regions_dir, file))

    circles.each do |circle|
      loc = circle[:loc]
      chunk_src = mcafile.chunk(loc[:chunk_index])[2]
      chunk = NBTFile.read(chunk_src)[1]

      chunk['Level']['LightPopulated'] = NBTFile::Types::Byte.new(0)

      section = chunk['Level']['Sections'].items[loc[:section_y]]

      # Confirm section Y ... OK
      if section['Y'].value != loc[:section_y]
        ap circle
        p section['Y'].value
        exit
      end

      blocks = section['Blocks'].value
      data   = section['Data'].value

      block = blocks[loc[:block_index]]
      block = block.unpack('C')[0]

      # Confirm block type ... OK
      # [air, stone, grass, dirt, tallgrass]
      unless [0, 1, 2, 3, 31].include?(block)
        puts block
        ap circle
        exit
      end

      if block != 0
        blocks[loc[:block_index]] = "\x0"
        MCAFile.halfbyte(data, loc[:block_index], 0)
        puts "Update block: #{block}"
        ap circle
      end

      height_map = chunk['Level']['HeightMap'].value()
      h = height_map[loc[:block_index] % 256] - 1
      if loc[:y] == h
        # Could be deeper..
        height_map[loc[:block_index] % 256] = h
        puts "Update height map (#{circle[:word]}): #{h}"
      else
        puts "Skip update height map (#{circle[:word]}): #{loc[:y]} #{h}"
      end

      # Update SkyLight, remove plant above the hole (loc2, loc3)
      loc2 = circle[:loc2]
      section2 = chunk['Level']['Sections'].items[loc2[:section_y]]

      if MCAFile.halfbyte(section2['SkyLight'].value, loc2[:block_index]) == 15
        MCAFile.halfbyte(section['SkyLight'].value, loc[:block_index], 15)
      end

      blocks = section2['Blocks'].value
      data   = section2['Data'].value
      block = blocks[loc2[:block_index]].unpack('C')[0]

      # [tall grass, red flower, yellow flower, tall plant]
      if [31, 38, 37, 175].include?(block)
        blocks[loc2[:block_index]] = "\x0"
        MCAFile.halfbyte(data, loc2[:block_index], 0)

        puts "Update loc2 block: #{block}"

        # Remove tall plant (Sunflower, Double tallgrass, etc.)
        if block == 175
          loc3 = circle[:loc3]
          section3 = chunk['Level']['Sections'].items[loc3[:section_y]]
          unless section3.nil?
            blocks = section3['Blocks'].value
            data   = section3['Data'].value

            block = blocks[loc3[:block_index]].unpack('C')[0]
            if block == 175
              blocks[loc3[:block_index]] = "\x0"
              MCAFile.halfbyte(data, loc3[:block_index], 0)

              puts "Update loc3 block: #{block}"
            end
          end
        end

        ap circle
      end

      save = true
      if save
        io = StringIO.new()
        NBTFile.write(io, '', chunk)
        io.seek(0)

        mcafile.write_chunk(loc[:chunk_index], io.read)
      end
    end
  end
end

execute(regions_dir)
