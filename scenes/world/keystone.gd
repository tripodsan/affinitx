extends RigidBody3D
class_name PyramidKeystone

@onready var base = $base
@onready var root = $base/root
@onready var collision = $collision
@onready var pickable_component:PickableComponent = $PickableComponent
@onready var scale_component:ScaleComponent = $base/root/ScaleComponent

var can_activate:bool

signal activation_changed(active:bool)

func _ready():
  top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)
  scale_component.scale_changed.connect(_on_scale_changed)
  _recalc()

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

func _recalc():
  can_activate = scale_component.scale_time == 1.0

func _on_scale_changed():
  var prev = can_activate
  _recalc()
  if prev != can_activate:
    activation_changed.emit(can_activate)
