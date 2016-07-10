#! /usr/bin/env ruby

affix_chars = [
               [1, 0],
               [0, 1],
               [1, 1],

               [0, 2],
               [1, 2],
               [2, 0],
               [2, 1],
               [2, 2],

               [0, 3],
               [1, 3],
               [2, 3],
               [3, 0],
               [3, 1],
               [3, 2],
               [3, 3],

               [0, 4],
               [1, 4],
               [2, 4],
               [3, 4],
               [4, 0],
               [4, 1],
               [4, 2],
               [4, 3],
               [4, 4],
]

# affix_patterns = affix_chars.map {|len| /^(.{#{len[0]}}).*(.{#{len[1]}})$/ }

patterns = {}
words = File.readlines(File.join(File.dirname(__FILE__), 'dicts/web2'))
words.each.with_index do |word, i|
  word.chomp!
  word.downcase!
  affix_chars.each do |c|
    next if word.length < c[0] + c[1]
    c1 = word[0...c[0]]
    c2 = word.reverse[0...c[1]].reverse
    pat = "#{c1}*#{c2}"

    if patterns[pat].nil?
      patterns[pat] = 0
    end
    patterns[pat] += 1
  end
end

patterns.each do |pat, count|
  puts "#{pat}\t#{count}"
end
