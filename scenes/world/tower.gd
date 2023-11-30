extends RigidBody3D
class_name Tower

const CARRY_DELTA = Vector3(0, 0.0, 0)

@onready var base = $base
@onready var collision:CollisionShape3D = $collision
@onready var collision_static:CollisionShape3D = $StaticBody3D/collision_static
@onready var pickable_component:PickableComponent = $PickableComponent
@onready var scale_component:ScaleComponent = $base/ScaleComponent

@onready var animation_player:AnimationPlayer = $AnimationPlayer

var _locked:bool = false

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

func lock():
  _locked = true
  collision.disabled = true
  collision_static.disabled = false

func _on_area_3d_body_entered(body):
  if body is Player and _locked:
    animation_player.play("open")

func grow():
  freeze = true
  scale_component.scale_max_reached.connect(_on_tower_grown)
  scale_component.set_scaling(true)

func _on_tower_grown():
  lock()
