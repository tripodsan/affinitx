@tool
extends StaticBody3D
class_name Block

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
    if mesh:
      mesh.material = v if v else default_material

func _ready():
  _recalc()

func _recalc():
  if mesh:
    mesh.size = Vector3(width, height, depth)
  if collision:
    collision.size = Vector3(width, height, depth)
