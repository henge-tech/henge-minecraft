class Circle
  CIRCLES = {
    8 => {
      'size' => [7, 2, 7],
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
      'size' => [11, 2, 11],
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
      'size' => [13, 2, 13],
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
      'size' => [15, 2, 15],
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

    palette << {
      'Name' => 'minecraft:mossy_cobblestone'
    }

    palette << {
      'Name' => 'minecraft:air'
    }

    palette
  end

  def positions(pattern)
    pos = {}
    pattern.split(/\n/).each.with_index do |line, y|
      line.split(//).each.with_index do |c, x|
        next if c == '.'
        pos[c] = [x, 1, y]
      end
    end
    pos.keys.sort.map { |c| pos[c] }
  end

  def structure(data)
    words = data[:words]

    nbt = StructureFile.new(@size)
    nbt.palette = @palette
    words.each.with_index do |word, idx|
      nbt.add_block(@states[idx], @positions[idx], sign(word))
    end

    moss_state = @states.last + 1
    air_state  = @states.last + 2

    words.length.times do |idx|
      pos = @positions[idx].dup
      pos[1] = 0
      nbt.add_block(moss_state, pos)
    end

    air_pos = @positions[0].dup
    air_pos[1] = 0
    air_pos[2] = 1
    nbt.add_block(air_state, air_pos)

    compound = ItemFrameEntity.build_structure_file_entry(air_pos, data)
    nbt.add_entity(compound)

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

  def self.build_structure(data)
    if @master[data[:words].length]
      @master[data[:words].length].structure(data)
    else
      p data[:words]
    end
  end
end
