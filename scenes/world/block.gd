@tool
extends StaticBody3D

var default_material:Material = preload('res://scenes/world/mountain-mat.tres')

@onready var mesh:BoxMesh = $mesh.mesh
@onready var collision:BoxShape3D = $collision.shape

@export_range(0.0, 100, 0.01, 'or_greater') var width:float = 1.0:
  set(v):
    if v > 0:
      width = v
      _recalc()

@export_range(0.0, 100, 0.01, 'or_greater') var depth:float = 1.0:
    set(v):
      if v > 0:
        depth = v
        _recalc()

@export_range(0.0, 100, 0.01, 'or_greater') var height:float = 1.0:
    set(v):
      if v > 0:
        height = v
        _recalc()

@export var material_override:Material = null:
  set(v):
    material_override = v
    _update_material()

func _ready():
  _recalc()
  _update_material()

func _recalc():
  if mesh:
    mesh.size = Vector3(width, height, depth)
  if collision:
    collision.size = Vector3(width, height, depth)

func _update_material():
  if mesh:
    mesh.material = material_override if material_override else default_material
