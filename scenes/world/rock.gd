extends RigidBody3D

@onready var root = $base/root
@onready var collision = $collision
@onready var scale_component:ScaleComponent = $base/root/ScaleComponent

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

func unfreeze():
  freeze = false
  max_contacts_reported = 0
  contact_monitor = false

func _on_body_exited(body):
  if freeze and get_contact_count() == 0:
    unfreeze.call_deferred()

#var pending_position:Vector3
#
#func _integrate_forces(state:PhysicsDirectBodyState3D):
#  if pending_position:
#    state.transform.origin = pending_position
#    pending_position = Vector3.ZERO
#
#func apply_scale(origin:Vector3, scale_factor:float):
#  pending_position = (global_position - origin) * scale_factor + origin
