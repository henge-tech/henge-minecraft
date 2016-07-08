#! /usr/bin/env ruby

# file, first score, middle pos, middle score, last score, last_line
score_data = [
  ['20050816.txt',   -1000.0, 10_000, 5000.0, 3000.0],
  ['20060406.txt',   -1000.0, 10_000, 8000.0, 5000.0],
  ['google-20k.txt', -1000.0, 10_000, 6000.0, 5000.0]
]

words = {};

score_data.each do |data|
  filename = data[0]
  words[filename] = {}

  lines = File.readlines(data[0])
  total = lines.length

  lines.each do |line|
    line.chomp!
    (linenum, word) = line.split(/\t/)
    word = word.downcase
    next if words[filename][word]

    linenum = linenum.to_i
    if linenum <= data[2]
      step = (data[3] - data[1]) / data[2]
      score = data[1] + step * (linenum - 1)
    else
      step = (data[3] - data[4]) / (total - data[2])
      score = data[3] - step * (linenum - data[2] - 1)
    end

    words[filename][word] = [linenum, score, word]
  end
end

all_words = {}

idx = 0
words.each do |filename, wordlist|
  wordlist.each do |word, data|
    unless all_words[word]
      all_words[word] = [word, [99999, 99999, 99999], [0,0,0]]
    end
    all_words[word][1][idx] = data[0]
    all_words[word][2][idx] = data[1]
  end
  idx += 1
end

all_words.each do |word, data|
  data[3] = data[1].inject(:+)
  data[4] = data[2].inject(:+)
end

all_words.values.sort {|a,b| b[4] <=> a[4]}.each.with_index do |data, i|
  puts "#{i + 1}\t#{sprintf('%.2f', data[4])}\t#{data[3]}\t#{data[0]}"
end

# print "#{ word }\t#{ data[0].join(',') }\t"
# printf("%.2f,%.2f,%.2f\n", *data[1])

