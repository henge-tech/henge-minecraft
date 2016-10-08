#! /usr/bin/env ruby


yaml_pat = File.expand_path('../../../wordset/circles/*.yml', __FILE__)

patterns = {}
Dir.glob(yaml_pat).each.with_index do |file, i|
  pattern = File.basename(file, '.yml')
  patterns[pattern] = i + 1
end

file = File.expand_path('../004-circles_list_edited.log', __FILE__)

circles = []
open(file) do |f|
  f.each_line do |line|
    line.chomp!
    line = line.split(/\t/)
    circle = {}
    circle[:coords] = line[0..2]
    circle[:pattern] = line[3]
    circle[:word] = line[4]
    circle[:id] = patterns[circle[:pattern]]
    circles << circle
  end
end

circles.sort {|a,b| a[:id] <=> b[:id] }.each do |circle|
  puts "#{circle[:id]}\t#{circle[:coords].join("\t")}\t#{circle[:pattern]}\t#{circle[:word]}"
end
