@tool
extends Node3D
class_name PyramidLaser

var wire_material:Material = preload("res://scenes/world/activation-wire-mat.tres")

@export var laser:Laser

@export var wire:MeshInstance3D

@export var activated:bool: set = set_activated

@export var pedestal:Pedestal

@onready var laser_pivot = $pedestal/laser_pivot

var tower_locked:bool: set = set_tower_locked

var target_locked:bool = false

# todo: handle edge case with several stones
var _keystone:PyramidKeystone

signal activation_changed()

func _ready():
  set_activated(activated)

func _process(_delta)->void:
  if target_locked:
    laser_pivot.look_at(laser.hit_position, Vector3(0, 1, 0), true)

func set_tower_locked(v:bool):
  if tower_locked != v:
    tower_locked = v
    set_activated(activated)
    if tower_locked:
      activation_changed.emit()

func set_activated(v:bool):
  if laser:
    laser.fire = tower_locked
    laser.on = v
  if pedestal:
    pedestal.enabled = v
  if wire:
    if v:
      wire.set_surface_override_material(0, wire_material)
    else:
      wire.set_surface_override_material(0, null)
  if v != activated:
    activated = v
    activation_changed.emit()

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
    activated = false

func _on_keystone_activation_changed(v:bool):
  activated = v

func lock_target():
  target_locked = true
  laser.lock_target()
