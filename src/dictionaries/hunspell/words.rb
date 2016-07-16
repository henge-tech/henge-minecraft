#! /usr/bin/env ruby

open('en_US.dic') do |io|
  io.each_line.with_index do |line, i|
    next if i == 0
    line.chomp!
    (word, afx) = line.split(/\//, 2)
    puts word
  end
end

