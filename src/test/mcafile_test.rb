require 'yaml'
require 'nbtfile'

require_relative 'test_helper'
require_relative '../lib/mcafile'
require_relative '../lib/nbtfile_patch'

class MCAFileTest < Test::Unit::TestCase
  def test_load_locations
    mcafile = MCAFile.new(File.expand_path('../data/r.1.4.mca', __FILE__))

    locs = []
    mcafile.locations.each.with_index do |loc, i|
      locs << [loc, i] if loc != [0, 0]
    end

    assert_equal(1024, mcafile.locations.length)
    assert_equal([[[2, 1], 528]], locs)
  end

  def test_load_locations2
    mcafile = MCAFile.new(File.expand_path('../data/r.1.-2.mca', __FILE__))
    locs = []
    mcafile.locations.each.with_index do |loc, i|
      locs << [loc, i] if loc != [0, 0]
    end

    expect = [
              [[45, 1], 704], [[44, 1], 705], [[46, 2], 736], [[43, 1], 737],
              [[42, 1], 738], [[11, 1], 739], [[39, 1], 768], [[38, 1], 769],
              [[37, 1], 770], [[27, 1], 771], [[55, 1], 772], [[40, 1], 800],
              [[41, 1], 801], [[36, 1], 802], [[35, 1], 803], [[32, 1], 804],
              [[50, 1], 805], [[31, 1], 832], [[28, 1], 833], [[30, 1], 834],
              [[33, 2], 835], [[29, 1], 836], [[54, 1], 837], [[18, 1], 864],
              [[21, 1], 865], [[14, 1], 866], [[22, 1], 867], [[13, 1], 868],
              [[51, 1], 869], [[20, 1], 896], [[19, 1], 897], [[26, 1], 898],
              [[17, 1], 899], [[9, 1], 900], [[52, 1], 901], [[2, 1], 928],
              [[23, 1], 929], [[16, 1], 930], [[24, 1], 931], [[56, 2], 932],
              [[48, 1], 933], [[4, 1], 960], [[3, 1], 961], [[25, 1], 962],
              [[15, 1], 963], [[10, 1], 964], [[53, 1], 965], [[5, 1], 992],
              [[6, 1], 993], [[8, 1], 994], [[7, 1], 995], [[12, 1], 996],
              [[49, 1], 997]
             ]

    assert_equal(1024, mcafile.locations.length)
    assert_equal(expect, locs)
  end

  def test_load_timestamps
    mcafile = MCAFile.new(File.expand_path('../data/r.1.4.mca', __FILE__))
    timestamps = []
    mcafile.timestamps.each.with_index do |ts, i|
      timestamps << [ts, i] if ts != 0
    end
    assert_equal([[1_470_269_820, 528]], timestamps)
  end

  def test_find_writable_sector
    mcafile = MCAFile.new(File.expand_path('../data/r.1.4.mca', __FILE__))

    empty_sectors = [[], 3]
    assert_equal(empty_sectors, mcafile.empty_sectors)
    assert_equal(3, mcafile.find_writable_sector(1))
    assert_equal(3, mcafile.find_writable_sector(2))
    assert_equal(3, mcafile.find_writable_sector(3))
  end

  def test_find_writable_sector2
    mcafile = MCAFile.new(File.expand_path('../data/r.1.-2.mca', __FILE__))
    empty_sectors = [[], 58]
    assert_equal(empty_sectors, mcafile.empty_sectors)
    assert_equal(58, mcafile.find_writable_sector(1))
    assert_equal(58, mcafile.find_writable_sector(2))
    assert_equal(58, mcafile.find_writable_sector(3))
  end

  def test_find_writable_sector3
    mcafile = MCAFile.new(File.expand_path('../data/r.-1.2.mca', __FILE__))

    # ap mcafile.locations.sort {|a,b| a[0] <=> b[0]}
    empty_sectors = [
                     [
                      [268, 1], [338, 1], [362, 1], [451, 1],
                      [458, 1], [535, 2], [539, 2]
                     ],
                     543
                    ]
    assert_equal(empty_sectors, mcafile.empty_sectors)
    assert_equal(268, mcafile.find_writable_sector(1))
    assert_equal(535, mcafile.find_writable_sector(2))
    assert_equal(543, mcafile.find_writable_sector(3))
    assert_equal(543, mcafile.find_writable_sector(4))
  end

  def test_chunk
    mcafile = MCAFile.new(File.expand_path('../data/r.1.4.mca', __FILE__))
    assert_nil(mcafile.chunk(527))
    assert_nil(mcafile.chunk(529))

    (length, ctype, chunk) = mcafile.chunk(528, false)
    assert_equal(899, length)
    assert_equal(2, ctype)

    exp_chunk = "x\x9C\xED\xDB\xDDn\xD30\x14\xC0q\x9F\xA6\xC3]\xC7\xC7^\x80w\xE0" \
    "\x19\xC6\x90@\x1A\xD2\xA4\r$.\xCB\x1A\xB1h][\xAD\x19\x02\xEE\xB9\xE7Qy\x83" \
    "\x92\xB4v\xFC\xD1.\xCD\xB4\xAD\xC0\xF2\xFF\x8D.=n||\xEC\xA4\xA8\xA2\xA6\xAF" \
    "T_\xED\x1C\xA5_\xD3\x91\xA8\xE7G\xD9\x97\xF3\xFCx2\xBD\x1E\r\xF2t\xA8\x12\xD5" \
    "\xFDq<\x99)\xA5~\xED\xA9\xDD\xB7i\xF9\xEA\xFB\xC1T))\x9A\xD4\xE1\x9A\xC7\xEB" \
    "\xE8qP\xF3\xA8\xEB\xD7\xB4\xFFM\xFD\x9A\xF4\xBFK\xDFm\xF4\xDF\x94\xEF\xB6\xFD" \
    "7=\x9A\xAC\xE7M\xFD\x9A\xDC\v\xB7\xED\xDF4G]\xFF&96\xF5\xDF\x94\xA7i\xFF\xBA" \
    "<w\xCD\xB1\xF5\x1AvU\xEF$=\xCB\xB3\xC9x\xD6/\xE2\x1D\xAD\x9E\x1C\x8C&g\x17\xC5" \
    "_\x16\xFBJ\xB7\x9C\x94?\xE5\xAF\xD5v\xD1\xA6Y\xAA8:\xC5\x1C\xC5\xA4\xA9\x9AE" \
    "\xFB]u\x90]\xEC\xA8\xAE5|Y\xA2r\\j\xEF\x85\xA0\x16\t\x9E-\xEB\x14q\xA5\xC4\xCF" \
    "\xA2\"\xCC\x80n\x86\xB2hYL\xCB[\x06Y6\xBB<R\x8D'n`\x11\xF7\xAAMe+\xAF\x06\xF4" \
    "\x12\x8A\xAD\xB4j\fSDk_\xAD\xA7h?O5+s1\xC5\xBBX\"\xFE\xC9\xB6\"m&hz,'k\xD9:\xDC" \
    "\f\xDDo\xEF\"\xD9\x99\xDB5\xAC\xBA\xD81L21-\xEE\x86\xB1\xEDb\xEF\x1E\xD7\xE8" \
    "\x16\xDD]\x16\x9BQln\e\xBA:l\xE5\xE1\\t\xF5\xC7%rKf\x06\x10\xAD\xA3\x1Cv.\x11" \
    "\x1D4ko\xE8\xB8\x8B^\xED\xEE\xCE\xD3U\xECn\x01?Mtz\x9C#\x1A\x7F\xF5\x85\x95\xD8" \
    "\xAB\xD4\xBB\xE0\x12^s\x00\x00\x00\xA0\x05\xB4\xEA\x9D\\|_\xFCc\xA2R=\x05\x00" \
    "\x00\xDAG\x94|RZ\xF5\x17_\x10\xF0\xA9\x00\x00\x80\x16\xD3\xAA{8\xC8\a|\x14\x00" \
    "\x00\xA0\xA5\x82\xDD\x83\x7F\xFB\xDB\v\x00\x00\x00\x00\x00\xF0\xF0\xD8=\b\x00" \
    "@\xEB\x95\xBB\a\x85\xDD\x83\x00\x00\x80\xDD\x83\x00\x00\xB4\x1C\xBB\a\xF1h\x95" \
    "7x\x1C\xFB-\xF6M\xB0\xED\xBA\x1EJ<\x93xr\xF1t\x1F\xDD\xFC\xE3\xB8\xD9\xF5\xDF" \
    "Be\xFF\x866\xCD\x15\x00\x00\x00\x9B\xB1{\x10\x00\x80\xD6+w\x0Fv\xD8=\b\x00\x00" \
    "\xD8=\b\x00@\xCB\xB1{\x10\x00\x00\x00\x00P#)~\xBCh\xE9\xC6\xD8\xB6m\xA9\xB8\xE6" \
    "\xC2ix\xED\xB5\x13J\x82\xB8\x8Al\x9C\xF8q\xB2\x89\x04O%J!QCT\x90W\xFD\xEA\x92" \
    "\xAFmX=\xC1[\x03v\x0F\x02\x00\xD0z\xE5\xEE\xC1\x84\xDD\x83\x00\x00\x80\xDD\x83" \
    "\x00\x00\xB4\xDC\xEA\xEE\xC1\x9Ao?6\x7F\x17\xF2Ht\x96\x9A\xC6\x9D\r\xB1m{\xD8" \
    "\xA2\xEFIY\xA8\xB99\x12;\x15\e\xDB\x89\x998\no\x8Cm[g\x8D$\x8C\xAA\x12\x82\x15" \
    "\x8C\xE35+\xBC~\xC5k/\xC1\xFA\x1E\xDE\x9B#\x8C\x8A\xF8\xDE\xDF~q\xCENTB\xB4" \
    "\xA05+\x1C\xC7\xA6\xA5\xEE\x12\xAC\xEF\x01\x00\x00\x00\xA0\x15\xD8=\xB8\xE2\xF7" \
    "|>_w\x9CG\xC7\xF2\xD9\xC3\x8C^\xE4]\x1E\xE6\xE6\xD0\x809\xD3\xD47\xB7\x99\x82" \
    "\x82\xBD\xC2_\x98\xC1\xEC\xB1z\x01\x00\xD0F\xE5\xEE\xC1.\xBB\a\x01\x00\x00\xBB" \
    "\a\x01\x00h\xB9\xAE\xEA\x1F\rf\xF9\x87\xE9p\x90\xA7\xCB\xA6\xE4g\xB9\xA50\x9B" \
    "\\\xA6\xB3\xC5\xFF?\xFC\xFF\xBD,\x05\xC1-\xE2\xAEz\xF6n|>\xF8\x9C\xE5\xE9\xF04" \
    "\xBBL\xED\xCA%\xAA\xFB\xEDxR,\x91z%j\xFF4\xBD\xBA\x1Ad\xE3\xE3\xC9\xF4zT\xAC" \
    "\xE4P\xED\xAA\xA7\xA7\xD9(}3\xCE\xB3<+W\xB2\xB0\xABzA\\\xE4\xD8+?\x89}L\xAFf" \
    "\xD9d\xBC\xD8J\xF6\a\xEA/t\xC2".b

    assert_equal(exp_chunk.length, length - 1)
    assert_equal(exp_chunk, chunk)
  end

  def test_chunk_io
    mcafile = MCAFile.new(File.expand_path('../data/r.1.4.mca', __FILE__))
    (list, ctype, chunk_src) = mcafile.chunk(528)

    input  = StringIO.new(chunk_src, 'rb:binary')
    output = StringIO.new()

    yaml = YAML.dump(NBTFile.load(input))

    expect = File.read(File.expand_path('../data/r.1.4.yml', __FILE__))
    assert_equal(expect.split(/\n/), yaml.split(/\n/))
  end

  def with_tmp_file
    tmpfile = File.expand_path('../data/tmp.mca', __FILE__)
    begin
      yield(tmpfile)
    ensure
      FileUtils.rm(tmpfile) if File.exist?(tmpfile)
    end
  end

  def test_write_chunk
    with_tmp_file do |tmpfile|
      mcafile = MCAFile.new(tmpfile)

      # -- index: 5

      # 01234
      # TT111
      #   5
      dummy_chunk = ([1] * (4096 * 2) + [1, 2, 3, 4, 5]).pack('C*')
      mcafile.write_chunk(5, dummy_chunk, 555, false)

      # -- index: 3

      # 012345
      # TT1112
      #   5  3
      dummy_chunk = ([2] * 8).pack('C*')
      mcafile.write_chunk(3, dummy_chunk, 333, false)

      locs = []
      mcafile.locations.each.with_index do |loc, i|
        locs << [loc, i] if loc != [0, 0]
      end
      assert_equal([[[5, 1], 3],[[2, 3], 5]], locs)

      # -- index: 5 (delete)

      # 012345
      # TT...2
      #      3
      mcafile.delete_chunk(5, -1)

      locs = []
      mcafile.locations.each.with_index do |loc, i|
        locs << [loc, i] if loc != [0, 0]
      end
      assert_equal([[[5, 1], 3]], locs)
      assert_equal([[[2, 3]], 6], mcafile.empty_sectors)

      # -- index: 1

      # 012345
      # TT33.2
      #   1  3
      dummy_chunk = ([3] * 4096 + [1, 2, 3, 4, 5]).pack('C*')
      mcafile.write_chunk(1, dummy_chunk, 111, false)

      # -- index: 99

      # 01234567
      # TT33.244
      #   1  399
      dummy_chunk = ([1, 2, 3] + [4] * 4096).pack('C*')
      mcafile.write_chunk(99, dummy_chunk, 999, false)

      locs = []
      mcafile.locations.each.with_index do |loc, i|
        locs << [loc, i] if loc != [0, 0]
      end
      assert_equal([[[2, 2], 1], [[5, 1], 3], [[6, 2], 99]], locs)
      assert_equal([[[4, 1]], 8], mcafile.empty_sectors)

      assert_nil(mcafile.chunk(5, false))

      (length, ctype, chunk_src) = mcafile.chunk(1, false)
      assert_equal(4096 + 5 + 1, length)
      assert_equal(2, ctype)
      assert_equal([3, 3, 3, 3], chunk_src.unpack('C4')) # check first 4 bytes

      (length, ctype, chunk_src) = mcafile.chunk(3, false)
      assert_equal(8 + 1, length)
      assert_equal(2, ctype)
      assert_equal([2, 2, 2, 2], chunk_src.unpack('C4'))

      (length, ctype, chunk_src) = mcafile.chunk(99, false)
      assert_equal(4096 + 3 + 1, length)
      assert_equal(2, ctype)
      assert_equal([1, 2, 3, 4, 4, 4], chunk_src.unpack('C6'))

      timestamps = []
      mcafile.timestamps.each.with_index do |ts, i|
        timestamps << [ts, i] if ts != 0
      end
      assert_equal([[111, 1], [333, 3], [555, 5], [999, 99]], timestamps)
    end
  end
end
