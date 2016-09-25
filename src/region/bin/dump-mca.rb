#! /usr/bin/env ruby

#
# Dump .mca file
#

$:.unshift(File.expand_path('../../lib', __FILE__))

require 'mcafile'

require 'yaml'
require 'stringio'
require 'zlib'
require 'awesome_print'

mcafile = File.open(ARGV[0], 'rb:ascii-8bit') { |io| MCAFile.load(io) }

if ARGV[1].nil?
  puts mcafile.to_yaml
else
  # ANSI color for blocks
  colors = {
    '01' => '37',
    '07' => '40',
    '02' => '32',
    '09' => '34',
    '3f' => '31'  # sign
  }

  # Dump Blocks
  mcafile.chunks.each do |chunk|
    chunk[1]['Level']['Sections'].each do |section|
      blocks = StringIO.new(section['Blocks'])
      puts "Y:" + section['Y'].to_s
      4096.times do |n|
        block_id = (blocks.read(1)).unpack('H2')[0]

        print "\033[#{colors[block_id]}m" if colors[block_id]
        print block_id
        print "\033[0m" if colors[block_id]
        print ' '

        puts if (n + 1) % 16 == 0
        puts "---------" if (n + 1) % 256 == 0
      end
      puts "=========="
    end
  end
end
