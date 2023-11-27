extends RigidBody3D

@onready var base = $base
@onready var root = $base/root
@onready var collision = $collision
@onready var scale_component:ScaleComponent = $base/root/ScaleComponent
@onready var pickable_component:PickableComponent = $PickableComponent

func _ready():
  scale_component.scale_current = randf_range(0.9, 1.1)
  var rot:Vector3 = Vector3(randf_range(0, TAU), randf_range(0, TAU), randf_range(0, TAU))
  root.rotate_x(rot.x)
  root.rotate_y(rot.y)
  root.rotate_z(rot.z)
  collision.rotate_x(rot.x)
  collision.rotate_y(rot.y)
  collision.rotate_z(rot.z)
  top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)

func unfreeze():
  freeze = false
  max_contacts_reported = 0
  contact_monitor = false

func _on_body_exited(_body):
  if freeze and get_contact_count() == 0:
    unfreeze.call_deferred()

func _on_picked_up():
  # reset all rotation when picked up
  root.rotation = Vector3.ZERO
  root.position = Vector3.ZERO
  collision.position = Vector3.ZERO
  collision.rotation = Vector3.ZERO
  base.position = Vector3.ZERO
  base.rotation = Vector3.ZERO

func _on_dropped():
  pass
