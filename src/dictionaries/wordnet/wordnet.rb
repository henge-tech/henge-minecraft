#! /usr/local/env ruby

require 'wordnet'

module WordNet
  class Lemma
    class << self
      def all
        lemmas = {}
        [:noun, :verb, :adj, :adv].each do |pos|
          lemmas[pos] = build_cache(pos)
        end
        lemmas
      end
    end
  end
end

if ARGV[0].nil?

  # dump all words
  lemmas = WordNet::Lemma.all
  words = []
  [:noun, :verb, :adj, :adv].each do |pos|
    words += lemmas[pos].keys
  end

  words = words.sort.uniq.map {|w| w.gsub(/_/, ' ') }

  # skip '100', '1950s', ...
  words = words.reject {|w| w =~ /^\d+(s)?$/ || w == '' }

  # skip '100th', '105th', '1000th', ...
  words = words.reject {|w| w =~ /^\d+(?:st|nd|rd|th)$/ }

  # skip 'atomic number 1', '2','3' ...
  words = words.reject {|w| w =~ /^(?:atomic number|element) \d+$/ }

  # skip '.22-caliber', '.22 calibre', '.38-caliber', '.45-caliber', ...
  words = words.reject {|w| w =~ /^\.\d+/ }

  puts words.join("\n")

else

  lemmas = WordNet::Lemma::find_all(ARGV[0])
  abort "not found" if lemmas.empty?

  lemmas.each do |lemma|
    puts
    puts "### Lemma (#{lemma}) ================================================================"
    puts

    lemma.synsets.each do |syn|
      puts
      puts "## Synset ----------------------------------------------------------------"
      puts

      p syn.words
      puts syn.gloss

      puts
      puts "  ==> Hypernyms"
      syn.hypernyms.each do |rel|
        print '  '
        p rel.words
        print '  '
        puts rel.gloss
      end

      puts
      puts "  ==> Hyponyms"
      syn.hyponyms.each do |rel|
        print '  '
        p rel.words
        print '  '
        puts rel.gloss
      end

      puts
      puts "  ==> Antonyms"
      syn.antonyms.each do |rel|
        print '  '
        p rel.words
        print '  '
        puts rel.gloss
      end
    end
  end
end
