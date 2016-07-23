#! /usr/bin/env ruby


dir = File.join(__dir__, '../circles/')

files = nil
map = nil
Dir.chdir(dir) do
  lines = %x{wc -l *.yml}
  map = Hash[lines.split(/\n/).map {|line| line.strip}.map {|line| token = line.split(/\s/); [token[1], token[0]] }]
end

open(File.join(__dir__, '../circles.md'), 'w') do |out|
  out.puts "# Wordsets"
  out.puts
  out.puts "| File           | Entries        |"
  out.puts "|:---------------|:---------------|"

  map.keys.sort.each do |key|
    next if key == 'total'
    if map[key] == '12'
      out.puts "|#{key.ljust(16)}|#{map[key].ljust(16)}|"
    else
      out.puts "|#{key.ljust(16)}|#{"  #{map[key]} *".ljust(16)}|"
    end
  end
end

