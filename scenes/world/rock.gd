extends RigidBody3D

@onready var collision = $collision
@onready var scale_component:ScaleComponent = ScaleComponent.from_parent(self)
@onready var pickable_component:PickableComponent = PickableComponent.from_parent(self)

func _ready():
  scale_component.scale_current = randf_range(0.9, 1.1)
  var rot:Vector3 = Vector3(randf_range(0, TAU), randf_range(0, TAU), randf_range(0, TAU))
  collision.rotate_x(rot.x)
  collision.rotate_y(rot.y)
  collision.rotate_z(rot.z)
  top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)

func check_unfreeze():
  if freeze and get_contact_count() == 0:
    freeze = false
    max_contacts_reported = 0
    contact_monitor = false

func _on_body_exited(_body):
  check_unfreeze.call_deferred()

func _on_picked_up():
  # reset all rotation when picked up
  collision.position = Vector3.ZERO
  collision.rotation = Vector3.ZERO
  # disable collision with player
  collision_layer &= ~32

func _on_dropped():
  collision_layer |= 32
  collision_mask |= 4

func _on_body_entered(node:Node3D):
  var hcmp:HitBoxComponent = HitBoxComponent.from_parent(node)
  if hcmp:
    print_debug('rock free:', node)
    queue_free()
