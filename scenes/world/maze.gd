extends RigidBody3D

@onready var base = $base
@onready var root = $base/root
@onready var collision = $collision
@onready var pickable_component:PickableComponent = $PickableComponent

func _ready():
  top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)

func _on_picked_up():
  # reset all rotation when picked up
  # TODO: fix orientation is correct!
  root.rotation = Vector3.ZERO
  root.position = Vector3.ZERO
  collision.position = Vector3.ZERO
  collision.rotation = Vector3.ZERO
  base.position = Vector3.ZERO
  base.rotation = Vector3.ZERO

func _on_dropped():
  pass
