@tool
extends StaticBody3D

class_name PuzzleTile

@onready var buttons = [
  [$button_n, Vector2i.UP],
  [$button_e, Vector2i.RIGHT],
  [$button_s, Vector2i.DOWN],
  [$button_w, Vector2i.LEFT]
]

@export var pos:Vector2i: set = set_pos

@export var size:Vector2i = Vector2i.ONE: set = set_size

signal tile_click(direction: Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready():
  for info in buttons:
    assert(!info[0].mouse_entered.connect(_on_mouse_entered));
    assert(!info[0].mouse_exited.connect(_on_mouse_exited));
    assert(!info[0].input_event.connect(_on_input_event.bind(info)));

func _on_input_event(camera, event, position, normal, shape_idx, info):
  if event is InputEventMouseButton and event.pressed:
#    print_debug(event, position, info)
    tile_click.emit(info[1])

func _on_mouse_entered():
  Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
  Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func set_pos(p:Vector2i):
  pos = p
  update_position()

func set_size(s:Vector2i):
  size = s
  update_position()

func update_position():
  position.x = pos.x - 0.5 + size.x * 0.5
  position.z = pos.y - 0.5 + size.y * 0.5
  scale.x = size.x
  scale.z = size.y
