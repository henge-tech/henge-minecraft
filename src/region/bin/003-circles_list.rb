#! /usr/bin/env ruby

require 'yaml'
require 'awesome_print'
require 'nbtfile'

require_relative '../lib/nbtfile_patch'
require_relative '../lib/mcafile'

STDOUT.sync = true

#
# convert 002-find_circles.log to circles_list.txt
#

circles_dir = ARGV[0]

def execute(circles_dir)
  word_to_patterns = {}
  Dir.glob(File.join(circles_dir, '*.yml')).each do |file|
    pattern = File.basename(file, '.yml')
    word = YAML.load(File.read(file))[0]
    word_to_patterns[word] ||= []
    word_to_patterns[word] << pattern
  end

  open(File.expand_path('../002-find_circles.log', __FILE__)) do |f|
    f.each_line do |line|
      next if line =~ /\A#/
      line.chomp!
      values = line.split(/\t/)
      word = values[0]
      patterns = word_to_patterns[word]
      if patterns.length != 1
        pattern = "XXX " + patterns.join("/")
      else
        pattern = patterns[0]
      end
      puts values[1..3].join("\t") + "\t" + pattern + "\t" + word
    end
  end

end

execute(circles_dir)
