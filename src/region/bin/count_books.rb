#! /usr/bin/env ruby

require 'awesome_print'
require 'nbtfile'
require 'optparse'
require 'stringio'

require_relative '../lib/nbtfile_patch'
require_relative '../lib/mcafile'

STDOUT.sync = true

def execute(dir_or_file)
  if File.directory?(dir_or_file)
    dir = dir_or_file
    total_framed = 0
    total_boxed = 0
    Dir.glob(File.join(dir, '*.mca')).each do |file|
      (framed, boxed) = count_books(file)
      total_framed += framed
      total_boxed  += boxed
    end
    puts "total: #{total_framed + total_boxed}\tframed: #{total_framed}\tboxed: #{total_boxed}"
  else
    count_books(dir_or_file)
  end
end

def count_books(file)
  region_quad = load_books(file)
  total_framed = 0
  total_boxed = 0

  region_quad.each.with_index do |books, qidx|
    boxed_count = books[:boxed].length
    framed_count = books[:framed].length
    total_count = framed_count + boxed_count
    if total_count > 0
      puts "#{File.basename(file)}(#{qidx})\ttotal: #{ total_count }\tframed: #{ framed_count }\tboxed: #{boxed_count}\t#{ '%.2f' % (boxed_count.to_f / total_count * 100) }%"
      total_framed += framed_count
      total_boxed += boxed_count
      unless books[:framed].empty?
        b = books[:framed].first
        puts "/tp @p #{b[:x]} #{b[:y] + 2} #{b[:z]}"
      end
    end
  end

  [total_framed, total_boxed]
end

def load_books(file)
  mca = MCAFile.new(file)

  result = [
            {framed: [], boxed: []},
            {framed: [], boxed: []},
            {framed: [], boxed: []},
            {framed: [], boxed: []}
           ]
  mca.each_chunk do |idx, chunk_src|
    chunk_local_x = idx % 32
    chunk_local_y = idx / 32

    chunk_local_x = chunk_local_x < 16 ? 0 : 1
    chunk_local_y = chunk_local_y < 16 ? 0 : 1
    qidx = chunk_local_y * 2 + chunk_local_x

    io = StringIO.new(chunk_src)

    (chunk_name, chunk) = NBTFile.load(io)

    chunk['Level']['TileEntities'].each do |entity|
      if entity['id'] == 'Chest'
        next if entity['Items'].nil?
        entity['Items'].each do |item|
          if item['id'] == 'minecraft:written_book'
            result[qidx][:boxed] << {
              title: item['tag']['title'],
              x: entity['x'],
              y: entity['y'],
              z: entity['z']
            }
          end
        end
      end
    end

    chunk['Level']['Entities'].each do |entity|
      if entity['id'] == 'ItemFrame' && entity['Item'].nil?
        # p entity
      elsif entity['id'] == 'ItemFrame' && entity['Item'] && entity['Item']['id'] == 'minecraft:written_book'
        result[qidx][:framed] << {
          title: entity['Item']['tag']['title'],
          x: entity['TileX'],
          y: entity['TileY'],
          z: entity['TileZ']
        }
      elsif entity['id'] == 'Item'
        # p entity['Item']['id']
      else
        # puts entity['id']
      end
    end
  end

  result
end

execute(ARGV[0])
