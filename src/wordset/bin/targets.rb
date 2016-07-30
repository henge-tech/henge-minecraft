#! /usr/bin/env ruby

#
# Find wordset/data/*.yml files, which has not yet been edited.
#

require 'yaml'

Dir.chdir(File.join(__dir__, '..'))

wordsets = nil
Dir.chdir('data') do
  wordsets = Dir.glob('*.yml').map {|f| f.sub(/\.yml\z/, '') }
end

skips = YAML.load(File.read('skip.yml'))
wordsets -= skips

circles = nil
Dir.chdir('circles') do
  circles = Dir.glob('*.yml').map {|f| f.sub(/\.yml\z/, '') }
end

wordsets -= circles

concat = wordsets.join("\n")

def superset_rex(pattern)
  affix = pattern.split(/_/)
  prefix = ''
  affix[0].to_s.split(//).reverse.each do |c|
    if prefix.empty?
      prefix = "(?:#{c})?"
    else
      prefix = "(?:#{c}#{prefix})?"
    end
  end

  suffix = ''
  affix[1].to_s.split(//).each do |c|
    if suffix.empty?
      suffix = "(?:#{c})?"
    else
      suffix = "(?:#{suffix}#{c})?"
    end
  end

  return /^#{prefix}_#{suffix}$/
end

def subset_rex(pattern)
  affix = pattern.split(/_/)
  return /^#{affix[0]}.*_.*#{affix[1]}$/
end

supersets = []
subsets = []
circles.each do |cf|
  super_rex = superset_rex(cf)
  sub_rex = subset_rex(cf)

  supersets += concat.scan(super_rex)
  subsets += concat.scan(sub_rex)
end

wordsets -= supersets
wordsets -= subsets

wordsets = wordsets.reject { |w| w =~ /(?:s|ing|ed)\z/ }

wordsets = wordsets.select { |w| w =~ /#{ARGV[0]}/ }

tmp = []
wordsets.each do |pat|
  data = YAML.load(File.read(File.join('data', "#{pat}.yml")))

  hi = data['hi_scored_words_count']
  sc = data['scored_words_count']
  total = data['score']
  spw = total / (hi + sc)

  tmp << {pat: pat, hi: hi, sc: sc, total: total, spw: spw}
end
wordsets = tmp

wordsets = wordsets.sort do |a,b|
  x = (a[:hi] - 12).abs <=> (b[:hi] - 12).abs
  if x != 0
    x
  else
    a[:spw] <=> b[:spw]
  end
end

wordsets.each do |w|
  puts "#{w[:pat]}\thi:#{w[:hi]}\tsc:#{w[:sc]}\tspw:#{w[:spw]}"
end

# puts wordsets.join("\n")

# a(?:b(?:c)?)?_(?:(?:a)?b)?c
# end
