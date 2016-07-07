#! /usr/bin/env ruby

files = %w{
1-10000
10001-20000
20001-30000
30001-40000
40001-50000
50001-60000
60001-70000
70001-80000
80001-90000
90001-100000
}

concat = ''
files.each do |file|
  source = File.read(file)
  source.sub!(/.*?<\/h3>/m, '')
  source.sub!(/<!--.+/m, '')
  concat += source
end

puts concat.scan(/<a href="(.+?)".+?>(.+?)<\/a>/).select {|m| m[0] !~ /title=Wiktionary:/ }.map.with_index {|m, i| "#{ i + 1 }\t#{ m[1] }" }.join("\n")
