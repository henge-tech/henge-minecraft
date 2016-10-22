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
#   author: ht
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
#  - Name: minecraft:mossy_cobblestone
#

require 'nbtfile'
require 'yaml'
require 'awesome_print'

require_relative '../../lib/nbtfile_patch'
require_relative '../../lib/mcafile'
require_relative '../../lib/item_frame_entity'
require_relative '../../lib/mca_circle'
require_relative '../../lib/circle'
require_relative '../../lib/structure_file'

STDOUT.sync = true

list_file = File.expand_path('../../../region/bin/005-sort_and_add_id.log', __FILE__)
outdir = File.expand_path('../../../../structures/circles/', __FILE__)

mca_circles = MCACircle.load(ARGV[0], list_file)

mca_circles.each do |mca_file, circles|
  circles.each do |circle|
    structure = Circle.build_structure(circle[:words])
    structure.author = 'mindcraft'
    open(File.join(outdir, "#{circle[:pattern]}.nbt"), 'w') do |out|
      structure.write(out)
    end
  end
end
