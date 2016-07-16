#! /usr/bin/env ruby

words1 = File.readlines('../dicts/web2').map {|w| w.chomp}
words2 = File.readlines('../wordnet/wordnet-1.txt').map {|w| w.chomp}
words3 = File.readlines('../hunspell/words.txt').map {|w| w.chomp}

words = (words1 + words2 + words3).sort do |a,b|
  dca = a.downcase
  dcb = b.downcase
  dca == dcb ? a <=> b : dca <=> dcb
end.uniq

open('merged-cap.txt', 'w') do |out|
  out.puts words.join("\n")
end

merged = []
map = {}

words.each do |word|
  dc = word.downcase
  if map[dc]
    map[dc] << word
  else
    map[dc] = [word]
    merged << word
  end
end

open('merged.txt', 'w') do |out|
  out.puts merged.join("\n")
end

open('merged-capdup.txt', 'w') do |out|
  out.puts map.values.reject {|a| a.length <= 1 }.flatten.join("\n")
end
