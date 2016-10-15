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
      books = load_books(file)

      boxed_count = books[:boxed].length
      framed_count = books[:framed].length
      total_count = framed_count + boxed_count
      if total_count > 0
        puts "#{File.basename(file)}\ttotal: #{ total_count }\tframed: #{ framed_count }\tboxed: #{boxed_count}\t#{ '%.2f' % (boxed_count.to_f / total_count * 100) }%"
        total_framed += framed_count
        total_boxed += boxed_count
      end
    end
    puts "total: #{total_framed + total_boxed}\tframed: #{total_framed}\tboxed: #{total_boxed}"
  else
    file = dir_or_file
    books = load_books(file)
    ap books
    boxed_count = books[:boxed].length
    framed_count = books[:framed].length
    puts "#{File.basename(file)}\ttotal:#{ framed_count + boxed_count }\tframed:#{ framed_count }\tboxed:#{boxed_count}"
  end
end

def load_books(file)
  mca = MCAFile.new(file)

  result = {framed: [], boxed: []}
  mca.each_chunk do |idx, chunk_src|
    io = StringIO.new(chunk_src)

    (chunk_name, chunk) = NBTFile.load(io)

    chunk['Level']['TileEntities'].each do |entity|
      if entity['id'] == 'Chest'
        next if entity['Items'].nil?
        entity['Items'].each do |item|
          if item['id'] == 'minecraft:written_book'
            result[:boxed] << {
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
      if entity['id'] == 'ItemFrame' && entity['Item']['id'] == 'minecraft:written_book'
        result[:framed] << {
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
