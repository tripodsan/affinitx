@tool
extends Node3D
class_name PyramidLaser

var wire_material:Material = preload("res://scenes/world/activation-wire-mat.tres")

@export var laser:Laser

@export var wire:MeshInstance3D

@export var activated:bool: set = set_activated

# todo: handle edge case with several stones
var _keystone:PyramidKeystone

func _ready():
  set_activated(activated)

func set_activated(v:bool):
  activated = v
  if laser:
    laser.fire = v
    laser.on = v
  if wire:
    if v:
      wire.set_surface_override_material(0, wire_material)
    else:
      wire.set_surface_override_material(0, null)



func _on_trigger_body_entered(body):
  if not body is PyramidKeystone: return
  if _keystone:
    _keystone.activation_changed.disconnect(_on_keystone_activation_changed)
  _keystone = body
  _keystone.activation_changed.connect(_on_keystone_activation_changed)
  activated = _keystone.can_activate

func _on_trigger_body_exited(body):
  if body == _keystone:
    _keystone.activation_changed.disconnect(_on_keystone_activation_changed)
    _keystone = null
    activated = false

func _on_keystone_activation_changed(v:bool):
  activated = v
