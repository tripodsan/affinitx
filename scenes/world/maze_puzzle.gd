extends Node3D

@onready var maze = $maze

var _maze_scene = preload("res://scenes/world/maze.tscn")

var _saved_maze_transform:Transform3D
var _saved_maze_position:Vector3

func _ready():
  _saved_maze_transform = maze.transform
  _saved_maze_position = maze.position
  Global.game_event.connect(_on_game_event)
  maze.hitbox_entered.connect(_on_hitbox_entered)

func _on_game_event(evt:Global.GAME_EVENT):
  if evt == Global.GAME_EVENT.PLAYER_KILLED:
    print_debug('player killed entered')
    _reset_maze()

func _on_hitbox_entered(_hcmp:HitBoxComponent):
  print_debug('hitbox entered')
  _reset_maze()

func _reset_maze():
  maze.queue_free()
  maze = _maze_scene.instantiate()
  add_child(maze)
  maze.transform = _saved_maze_transform
  maze.hitbox_entered.connect(_on_hitbox_entered)


