#! /usr/bin/env ruby

#
# http://minecraft.gamepedia.com/Structure_block_file_format
#
# TAG_Compound       - The root tag.
#   TAG_Int          - version: Version of the structure (Currently 1)
#   TAG_String       - author: Name of the player who created this structure
#   TAG_List         - size: 3 TAG_Int describing the size of the structure
#   TAG_List         - palette: Set of different block state used in the structure.
#     TAG_Compound   - Block state
#       TAG_String   - Name: Id of the block
#       TAG_Compound - Properties: List of block state properties, with [name] being the name of the block state property
#         TAG_String - [name]: value of the property
#   TAG_List         - blocks: List of individual block in the structure.
#     TAG_Compound   - Individual block
#       TAG_Int      - state: Index of the block state in the palette
#       TAG_List     - pos: 3 TAG_Int describing the position of this block
#       TAG_Compound - nbt: nbt of the block (optional)
#   TAGList          - entities: List of entities in the structure
#     TAG_Compound   - Entity
#       TAG_List     - pos: 3 TAG_Double describing the exact position of the entity
#       TAG_List     - blockPos: 3 TAG_Int describing the block position of the entity
#       TAG_Compound - nbt: nbt of the entity (required)
#
#
# air and void
#
# - ''
# - version: 1
#   author: kkoseki
#   size:
#   - 1
#   - 1
#   - 2
#   palette:
#   - Name: minecraft:air
#   blocks:
#   - state: 0
#     pos:
#     - 0
#     - 0
#     - 0
#   entities: []
#
#
# sign block
#
#  - state: 1
#    pos:
#    - 7
#    - 0
#    - 0
#    nbt:
#      id: Sign
#      Text1: '{"text":"A"}'
#      Text2: '{"text":""}'
#      Text3: '{"text":""}'
#      Text4: '{"text":""}'
#
#
#  palette
#
#  - Name: minecraft:standing_sign
#    Properties:
#      rotation: '0'
#

require 'nbtfile'
require 'yaml'

module NBTFile
  class Emitter
    attr_reader :gz
  end

  def self.write_with_mtime(io, name, body, mtime)
    emit(io) do |emitter|
      # Set timestamp to generate same gzip binary every time.
      emitter.gz.mtime = mtime

      writer = Writer.new(emitter)
      writer.write_pair(name, body)
    end
  end
end

class StructureFile
  include NBTFile
  attr_accessor :author

  def initialize(size)
    @version = 1
    @size = size
    @author = nil

    @blocks = []
    @palette = []
  end

  def nbt(obj)
    if obj.instance_of? ::Hash
      hash_to_compound(obj)
    elsif obj.instance_of? ::Array
      array_to_list(obj)
    elsif obj.instance_of? ::Fixnum
      Types::Int.new(obj)
      # :
    elsif obj.instance_of? ::String
      Types::String.new(obj)
    else
      obj
    end
  end

  def array_to_list(arr)
    list = arr.map {|o| nbt(o) }
    if list.empty?
      Types::List.new(Types::Compound, []) # FIXME
    else
      Types::List.new(list[0].class, list)
    end
  end

  def hash_to_compound(hash)
    comp = {}
    hash.each { |k, v| comp[k] = nbt(v) }
    return Types::Compound.new(comp)
  end

  def add_palette(name, properties)
    palette = {
      'Name' => name,
      'Properties' => properties
    }
    @palette << palette
  end

  def palette=(palette)
    @palette = palette
  end

  def add_block(state, pos, nbt)
    block = {
      'state' => state,
      'pos' => pos,
      'nbt' => nbt
    }
    @blocks << block
  end

  def to_hash
    {
      'version' => @version,
      'author' => @author,
      'size' => @size,
      'palette' => @palette,
      'blocks' => @blocks,
    }
  end

  def write(io)
    NBTFile::write_with_mtime(io, '', nbt(to_hash), 1_470_000_000)
  end
end

class Circle
  CIRCLES = {
    8 => {
      'size' => [7, 1, 7],
      'rotations' => [0, 2, 4, 6, 8, 10, 12, 14],
      'states'    => [0, 1, 2, 3, 4,  5,  6,  7],
      'pattern'   => <<'EOT',
...A...
.H...B.
.......
G.....C
.......
.F...D.
...E...
EOT
    },

    12 => {
      'size' => [11, 1, 11],
      'rotations' => [0, 1, 3, 4, 5, 7, 8, 9, 11, 12, 13, 15],
      'states'    => [0, 1, 2, 3, 4, 5, 6, 7,  8,  9, 10, 11],
      'pattern'   => <<'EOT',
.....A.....
...L...B...
...........
.K.......C.
...........
J.........D
...........
.I.......E.
...........
...H...F...
.....G.....
EOT
    },

    16 => {
      'size' => [13, 1, 13],
      'rotations' => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      'states'    => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      'pattern'   => <<'EOT',
....P.A.B....
.............
..O.......C..
.............
N...........D
.............
M...........E
.............
L...........F
.............
..K.......G..
.............
....J.I.H....
EOT
    },

    20 => {
      'size' => [15, 1, 15],
      'rotations' => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      'states'    => [0, 1, 2, 2, 3, 4, 5, 6, 6, 7, 8, 9, 10, 10, 11, 12, 13, 14, 14, 15],
      'pattern'   => <<'EOT',
.....T.A.B.....
...S.......C...
...............
.R...........D.
...............
Q.............E
...............
P.............F
...............
O.............G
...............
.N...........H.
...............
...M.......I...
.....L.K.J.....
EOT
    }
  }

  def initialize(opts)
    @size = opts['size']
    @states = opts['states']
    @palette = palette(opts['rotations'])
    @positions = positions(opts['pattern'])
  end

  def palette(rotations)
    palette = []
    rotations.each do |rot|
      palette << {
        'Name' => 'minecraft:standing_sign',
        'Properties' => { 'rotation' => rot.to_s }
      }
    end
    palette
  end

  def positions(pattern)
    pos = {}
    pattern.split(/\n/).each.with_index do |line, y|
      line.split(//).each.with_index do |c, x|
        next if c == '.'
        pos[c] = [x, 0, y]
      end
    end
    pos.keys.sort.map { |c| pos[c] }
  end

  def structure(words)
    nbt = StructureFile.new(@size)
    nbt.palette = @palette
    words.each.with_index do |word, idx|
      nbt.add_block(@states[idx], @positions[idx], sign(word))
    end
    nbt
  end

  def sign(word)
    word = word.gsub(/\\/, '\\').gsub(/\"/, '\"')
    {
      'id' => 'Sign',
      'Text1' => '{"text":""}',
      'Text2' => "{\"text\": \"#{word}\"}",
      'Text3' => '{"text":""}',
      'Text4' => '{"text":""}',
    }
  end

  @master = {}

  CIRCLES.each do |key, circle|
    @master[key] = new(circle)
  end

  def self.build_structure(words)
    if @master[words.length]
      @master[words.length].structure(words)
    else
      p words
    end
  end
end

outdir = File.join(__dir__, '../../../structures/circles/')
Dir.chdir(File.join(__dir__, '../circles')) do
  Dir.glob('*.yml') do |file|
    pattern = File.basename(file, '.*')

    words = YAML.load(File.read(file))
    structure = Circle::build_structure(words)
    structure.author = 'mindcraft'
    open(File.join('../../../structures/circles/', "#{pattern}.nbt"), 'w') do |out|
      structure.write(out)
    end
  end
end
