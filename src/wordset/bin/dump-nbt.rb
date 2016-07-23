#! /usr/bin/env ruby

require 'nbtfile'
require 'yaml'

nbt = NBTFile.load(File.read(ARGV[0]))
puts YAML.dump(nbt)
