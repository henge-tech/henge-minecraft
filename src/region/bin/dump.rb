#! /usr/bin/env ruby

#
# Dump .mca file
#


require 'yaml'
require 'stringio'
require 'zlib'
require 'awesome_print'
require 'nbtfile'

require_relative '../lib/nbtfile_patch'
require_relative '../lib/mcafile'

mcafile = MCAFile.new(ARGV[0])

if ARGV[1].nil?
  data = {'locations' => mcafile.locations, 'timestamps' => mcafile.timestamps}
  data['chunks'] = {}

  mcafile.each_chunk do |idx, chunk_src|
    data['chunks'][idx] = NBTFile.load(chunk_src)
  end
  puts YAML::dump(data)
else
  # ANSI color for blocks
  colors = {
    '01' => '37',
    '07' => '40',
    '02' => '32',
    '09' => '34',
    '3f' => '31' # sign
  }

  # Dump Blocks
  mcafile.each_chunk do |idx, chunk_src|
    chunk = NBTFile.load(chunk_src)[1]

    puts '=========='
    puts "index: #{idx}"

    chunk['Level']['Sections'].each do |section|
      blocks = StringIO.new(section['Blocks'])
      puts
      puts 'Y:' + section['Y'].to_s
      4096.times do |n|
        puts '---------' if n % 256 == 0
        block_id = (blocks.read(1)).unpack('H2')[0]

        print "\033[#{colors[block_id]}m" if colors[block_id]
        print block_id
        print "\033[0m" if colors[block_id]
        print ' '

        puts if (n + 1) % 16 == 0
      end
    end
  end
end
