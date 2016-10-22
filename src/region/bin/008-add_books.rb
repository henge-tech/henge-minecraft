#! /usr/bin/env ruby

#
# Add item frames with books
#

require 'yaml'
require 'stringio'
require 'awesome_print'
require 'nbtfile'

require_relative '../../lib/nbtfile_patch'
require_relative '../../lib/mcafile'
require_relative '../../lib/item_frame_entity'
require_relative '../../lib/mca_circle'

STDOUT.sync = true

regions_dir = ARGV[0]
circles_dir = ARGV[1]

def execute(regions_dir, circles_dir)
  list_file = File.expand_path('../005-sort_and_add_id.log', __FILE__)
  mca_circles = MCACircle.load(circles_dir, list_file)

  mca_circles.each do |mca_file, circles|
    # next if mca_file != 'r.-1.0.mca'
    mcafile = MCAFile.new(File.join(regions_dir, mca_file))

    circles.each do |circle|
      entity = ItemFrameEntity.build(circle)

      ap circle
      ap entity

      loc = circle[:loc]
      chunk_src = mcafile.chunk(loc[:chunk_index])[2]
      chunk = NBTFile.read(chunk_src)[1]
      if chunk['Level']['Entities'].items().length == 0

        type = NBTFile::Types::Compound
        chunk['Level']['Entities'] = NBTFile::Types::List.new(type, [entity])
      else
        chunk['Level']['Entities'] << entity
      end

      if true
        io = StringIO.new()
        NBTFile.write(io, '', chunk)
        io.seek(0)
        mcafile.write_chunk(loc[:chunk_index], io.read)
      end
    end
  end
end

execute(regions_dir, circles_dir)
