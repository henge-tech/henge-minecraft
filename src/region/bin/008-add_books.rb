#! /usr/bin/env ruby

#
# Add item frames with books
#

require 'yaml'
require 'securerandom'
require 'stringio'
require 'awesome_print'
require 'nbtfile'

require_relative '../../lib/nbtfile_patch'
require_relative '../../lib/mcafile'
require_relative '../../lib/item_frame_entity'

STDOUT.sync = true

regions_dir = ARGV[0]
circles_dir = ARGV[1]

def execute(regions_dir, circles_dir)

  list_file = File.expand_path('../005-sort_and_add_id.log', __FILE__)

  mca_circles = {}
  open(list_file) do |f|
    f.each_line do |line|
      line.chomp!
      data = line.split(/\t/)
      circle = {}
      circle[:id] = data[0]
      xyz = data[1..3].map(&:to_i)
      circle[:pattern] = data[4]

      loc  = MCAFile.coords_to_mca(xyz[0], xyz[2] + 1, xyz[1] - 1)

      circle[:loc] = loc
      circle[:words] = YAML.load(File.read(File.join(circles_dir, circle[:pattern] + '.yml')))

      mca_circles[loc[:mcafile]] ||= []
      mca_circles[loc[:mcafile]] << circle
    end
  end

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
