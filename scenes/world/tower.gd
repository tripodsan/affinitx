extends RigidBody3D
class_name Tower

const CARRY_DELTA = Vector3(0, 0.2, 0)

@onready var base = $base
@onready var collision = $collision
@onready var pickable_component:PickableComponent = $PickableComponent

func _ready():
  top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)

func _on_picked_up():
  collision.position = CARRY_DELTA
  collision.rotation = Vector3.ZERO
  base.position = CARRY_DELTA
  base.rotation = Vector3.ZERO

func _on_dropped():
  collision.position = Vector3.ZERO
  base.position = Vector3.ZERO
