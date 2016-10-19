module ItemFrameEntity
  include NBTFile::Types;

  def self.build(circle)
    cp = Compound.new()

    motion = List.new(Double)
    motion << Double.new(0.0)
    motion << Double.new(0.0)
    motion << Double.new(0.0)
    cp['Motion'] = motion

    cp['Facing'] = Byte.new(0)

    uuid = uuid64()
    cp['UUIDLeast'] = Long.new(uuid[1]);

    cp['ItemRotation'] = Byte.new(0)
    cp['Invulnerable'] = Byte.new(0)
    cp['Air'] = Short.new(300)
    cp['OnGround'] = Byte.new(0)
    cp['Dimension'] = Int.new(0)
    cp['PortalCooldown'] = Int.new(0)

    rotation = List.new(Float)
    rotation << Float.new(0.0)
    rotation << Float.new(0.0)
    cp['Rotation'] = rotation

    cp['FallDistance'] = Float.new(0.0)
    cp['Item'] = build_book(circle)
    cp['ItemDropChance'] = Float.new(1.0)
    cp['UUIDMost'] = Long.new(uuid[0])

    pos = List.new(Double)
    pos << Double.new(circle[:loc][:x])
    pos << Double.new(circle[:loc][:y])
    pos << Double.new(circle[:loc][:z])
    cp['Pos'] = pos
    cp['Fire'] = Short.new(0)
    cp['TileY'] = Int.new(circle[:loc][:y])
    cp['id'] = String.new('ItemFrame')
    cp['TileX'] = Int.new(circle[:loc][:x])
    cp['TileZ'] = Int.new(circle[:loc][:z])

    cp
  end

  def self.uuid64
    hex = SecureRandom.uuid.gsub('-', '')
    uuid = []
    uuid[0] = hex[0..15].hex
    uuid[1] = hex[16..31].hex

    # To signed long (64bit)
    # https://docs.ruby-lang.org/ja/latest/doc/pack_template.html
    uuid.map { |u| u[63] == 1 ? -((u ^ 0xffff_ffff_ffff_ffff) + 1) : u }
  end

  def self.build_book(circle)
    cp = Compound.new()

    cp['id'] = String.new('minecraft:written_book')
    cp['Count'] = Byte.new(1)

    tag = Compound.new()

    id = circle[:id]
    pattern = circle[:pattern]
    coords = "#{circle[:loc][:x]} #{circle[:loc][:y]} #{circle[:loc][:z]}"

    pages = []
    pages << '{"text":"\n\n\n\n\n     ' + "##{id}   #{pattern}" + '\n"}'
    unit = circle[:words].length / 4
    4.times do |i|
      words = circle[:words][i * unit, unit]
      words = words.join('\n   ')
      pages << '{"text":"\n\n\n   ' + words + '"}'
    end
    pages << '{"text":""}'
    pages << '{"text":"\n\n\n\n\n     ' + coords + '"}'

    tag['pages'] = List.new(String, pages.map {|s| String.new(s)})

    tag['author'] = String.new('ht')
    tag['title'] = String.new("##{id} #{pattern}")
    tag['resolved'] = Byte.new(1)
    cp['tag'] = tag

    cp['Damage'] = Short.new(0)
    cp
  end
end
