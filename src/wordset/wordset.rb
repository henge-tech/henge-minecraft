#! /usr/bin/env ruby

require 'yaml'

scores = {}
File.open(File.join(__dir__, '../frequency/scores.txt')) do |io|
  io.each_line do |line|
    line.chomp!
    (pos, score, freq, word) = line.split(/\t/)
    unless scores[word]
      scores[word] = pos.to_i
    end
  end
end

counts = {}
count_file = File.join(__dir__, 'count.txt')

File.open(count_file) do |io|
  io.each_line.with_index do |line, i|
    line.chomp!
    (pat, count) = line.split(/\t/)
    counts[pat] = count.to_i
  end
end

words = File.read(File.join(__dir__, '../dicts/web2'))

counts_len = counts.length

counts.each.with_index do |(pat, count), i|
  next if count < 5 || 200 < count

  print '.' if i % 10 == 0
  if i % 100 == 0
    puts "#{i}/#{counts_len}"
  end

  pat_rex = pat.split(/\*/)
  pat_rex = /^#{pat_rex[0]}.*#{pat_rex[1]}$/

  match_words = words.scan(pat_rex)

  word_scores = {}
  total_score = 0
  scored_words = {}
  not_scored_words = []
  match_words.each do |w|
    sc = scores[w] || 0
    word_scores[w] = sc
    total_score += sc
    if sc > 0
      scored_words[w] = sc
    else
      not_scored_words << w
    end
  end

  out_file = pat.sub(/\*/, '_') + '.yml'
  out_file = File.join(__dir__, 'data', out_file)

  scored_words_count = scored_words.length

  if 8 <= scored_words_count && scored_words_count <= 40
    data = {}
    data['pattern'] = pat
    data['scored_words_count'] = scored_words_count
    data['total_words'] = match_words.length
    data['score'] = total_score
    data['score_per_word'] = total_score / scored_words_count
    data['pickup'] = []
    data['scored_words'] = scored_words
    data['not_scored_words'] = not_scored_words

    File.open(out_file, 'w') do |out|
      out << YAML.dump(data)
    end
  end
end
