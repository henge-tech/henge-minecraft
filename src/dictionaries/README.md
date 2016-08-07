# Dictionaries

 * scowl
   * http://wordlist.aspell.net/dicts/
   * `en_US-large.txt` - 167,299 entries
 * basic
   * https://en.wiktionary.org/wiki/Appendix:1000_basic_English_words
   * `wiktionary-1000.txt` - 997 entries ([not 1,000](https://en.wiktionary.org/wiki/Appendix_talk:1000_basic_English_words))
 * dict/web2
   * http://web.mit.edu/freebsd/head/share/dict/
   * http://www.puzzlers.org/dokuwiki/doku.php?id=solving:wordlists:about:mcilroy (History)
   * `web2` - 235,924 entries
   * `web2a` - 76,205 entries
 * wordnet
   * https://wordnet.princeton.edu/
   * https://github.com/doches/rwordnet
   * `wordnet.txt` - 147,999 entries
   * `wordnet-1.txt` - 84,169 entries (words)
   * `wordnet-a.txt` - 63,830 entries (phrases)

[Scowl](http://wordlist.aspell.net/) seems to be the best word list I can found. There is nice checking tool.

 * http://app.aspell.net/lookup

`web2` doesn't include some very basic words (`anytime`, `box`).

```sh
$ ruby ./bin/word-diff.rb basic/wiktionary-1000.txt dict/web2
File1: 997
File2: 235924
Only in file1: 6 (0.60%)
Only in file2: 234884 (99.56%)

$ ruby ./bin/word-diff.rb --list1 basic/wiktionary-1000.txt dict/web2
anytime
box
colour
goodbye
neighbour
pleased
```

Wordnet is also difficult to use as the source of word list. There may be a reason, but I don't know why lacking these words.

```sh
$ ruby ./bin/word-diff.rb basic/wiktionary-1000.txt wordnet/wordnet-1.txt
File1: 997
File2: 84169
Only in file1: 46 (4.61%)
Only in file2: 82991 (98.60%)

$ ruby bin/word-diff.rb --list1 basic/wiktionary-1000.txt wordnet/wordnet-1.txt
and
anyone
anything
anytime
children
else
everyone
everybody
for
from
goodbye
her
hers
him
his
how
if
into
:
```

## Frequency data

 * Google Web Trillion Word Corpus, the 1/3 million most frequent words
   * http://norvig.com/ngrams/
   * `count_1w.txt` - 333,333 entries
 * wiktionary
   * https://en.wiktionary.org/wiki/Wiktionary:Frequency_lists
   * `20050816.txt` - 98,898 entries
   * `20060406.txt` - 36,662 entries
 * wordfreq-en
   * https://github.com/LuminosoInsight/wordfreq
   * `wordfreq-en.txt` - 419,809 entries

## Other sources

 * allwords2
   * http://www.puzzlers.org/dokuwiki/doku.php?id=solving:wordlists:about:start
   * `allwords2.txt` - 776,522 entries
 * google-10000-english
   * https://github.com/first20hours/google-10000-english
   * `20k.txt` - 20,000 entries (subset of the `count_1w.txt`)
