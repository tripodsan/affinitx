extends RigidBody3D
class_name PyramidKeystone

@onready var collision = $collision
@onready var pickable_component:PickableComponent = PickableComponent.from_parent(self)
@onready var scale_component:ScaleComponent = ScaleComponent.from_parent(self)

var can_activate:bool

signal activation_changed(active:bool)

func _ready():
  top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)
  scale_component.scale_changed.connect(_on_scale_changed)
  _recalc()

func _on_picked_up():
  # disable collision with player
  collision_layer &= ~32
  # reset all rotation when picked up
  collision.position = Vector3.ZERO
  collision.rotation = Vector3.ZERO

func _on_dropped():
  collision_layer |= 32

func _recalc():
  can_activate = scale_component.scale_time == 1.0

func _on_scale_changed():
  var prev = can_activate
  _recalc()
  if prev != can_activate:
    activation_changed.emit(can_activate)
