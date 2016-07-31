#! /usr/bin/env ruby

require 'yaml'
require 'shellwords'
require File.join(__dir__, 'superset.rb')

Dir.chdir(File.join(__dir__, '..'))

skips = YAML.load(File.read('skip.yml'))

circles = Dir.chdir('circles') do
  circles = Dir.glob('*.yml').map {|w| w.sub(/\.yml\z/, '') }
end
circles_str = circles.join("\n")

word = ARGV[0]
rex = ' ' + Shellwords.shellescape(word) + '\(:\|$\)'
list = Dir.chdir('data') do
  %x{grep -l '#{rex}' *.yml}.split(/\n/).map {|w| w.sub(/\.yml\z/, '') }
end

list.each do |pat|
  puts '-' * 80

  puts pat
  if skips.include?(pat)
    puts "SKIP"
    next
  end

  if circles.include?(pat)
    puts "EXISTS"
    puts File.read(File.join('circles', "#{pat}.yml"))
    next
  end

  data = YAML.load(File.read(File.join('data', "#{pat}.yml")))

  hi = data['hi_scored_words_count']
  sc = data['scored_words_count']
  total = data['score']
  spw = total / (hi + sc)
  puts "hi:#{hi}\tsc:#{sc}\tspw:#{spw}"

  super_rex = superset_rex(pat)
  sub_rex = subset_rex(pat)

  supersets = circles_str.scan(super_rex)
  subsets = circles_str.scan(sub_rex)

  unless supersets.empty?
    print "SUPERSET:"
    p supersets
  end

  unless subsets.empty?
    print "SUBSET:"
    p subsets
  end
end
