#! /usr/bin/env ruby

require 'awesome_print'
require 'nbtfile'

require_relative '../lib/nbtfile_patch'
require_relative '../lib/mcafile'

# x y z => x, z, y

if ARGV.length == 5
  args = ARGV.map {|a| a.to_i }
  ap MCAFile.block_to_mca(*args)
else
  ap MCAFile.coords_to_mca(ARGV[0].to_f, ARGV[2].to_f, ARGV[1].to_f)
end
