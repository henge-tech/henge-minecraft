#! /usr/bin/env ruby

#
# Dump single entity
#

require 'yaml'
require 'stringio'
require 'zlib'
require 'awesome_print'
require 'nbtfile'

require_relative '../lib/nbtfile_patch'
require_relative '../lib/mcafile'

mcafile = ARGV[0]
chunk_index = ARGV[1].to_i
entity_index = ARGV[2].to_i

def execute(mcafile, chunk_index, entity_index)
  mca = MCAFile.new(mcafile)
  chunk_src = mca.chunk(chunk_index)[2]
  chunk = NBTFile.read(chunk_src)[1]
  ap chunk['Level']['Entities'].items[entity_index]
end

execute(mcafile, chunk_index, entity_index)
