@tool
extends Node3D
class_name MazePiece

enum TYPE { CORNER, TEE, STRAIGHT, PLUS, END }

@export var type:TYPE = TYPE.CORNER: set = set_type

@onready var collision: CollisionShape3D = $collision
@onready var piece: Node3D = $collision/piece

@onready var types = {
  TYPE.CORNER: 'maze-corner',
  TYPE.TEE: 'maze-tee',
  TYPE.STRAIGHT: 'maze-straight',
  TYPE.PLUS: 'maze-plus',
  TYPE.END: 'maze-end'
}

var player_collision:StaticBody3D

@onready var pickable_component:PickableComponent = PickableComponent.from_parent(self)

func _ready():
  if not Engine.is_editor_hint():
    top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)
  _update()

func _on_picked_up():
  collision.position = Vector3(0.0, 0, 0.5)
  collision.rotation = Vector3.ZERO
  # disable player collision
  player_collision.collision_layer &= ~32
  # enable obstacle
  player_collision.collision_layer |= 64

func _on_dropped():
  # enable player collision
  player_collision.collision_layer |= 32
  # disable obstacle
  player_collision.collision_layer &= ~64

func set_type(t:TYPE):
  type = t;
  if Engine.is_editor_hint():
    _update()

func _update():
  var selected = types[type]
  for c in piece.get_children():
    var enabled = c.name == selected
    c.visible = enabled
    c.process_mode = Node.PROCESS_MODE_ALWAYS if enabled else PROCESS_MODE_DISABLED
    if enabled:
      player_collision = c.get_node('StaticBody3D')
