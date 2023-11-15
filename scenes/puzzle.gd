extends Node3D


@onready var tiles:Array[PuzzleTile] = [
  $puzzle_tile,
  $puzzle_tile2,
  $puzzle_tile3,
]

func _ready():
  for t in tiles:
    t.tile_click.connect(_on_tile_clicked.bind(t))

func _on_tile_clicked(dir:Vector2i, tile:PuzzleTile):
  if dir.x == 1:
    tile.size.x = 1 if tile.size.x == 2 else 2
  if dir.y == 1:
    tile.size.y = 1 if tile.size.y == 2 else 2
  if dir.x == -1:
    if tile.size.x == 1:
      tile.size.x = 2
      tile.pos.x -= 1
    else:
      tile.size.x = 1
      tile.pos.x += 1
  if dir.y == -1:
    if tile.size.y == 1:
      tile.size.y = 2
      tile.pos.y -= 1
    else:
      tile.size.y = 1
      tile.pos.y += 1
