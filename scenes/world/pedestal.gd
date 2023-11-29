@tool
extends StaticBody3D

class_name Pedestal

@onready var cube = $cube_container/cube

@export var preview:bool = false

@export var enabled:bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if not enabled: return

  if preview or not Engine.is_editor_hint():
    cube.rotate_x(0.5 * delta)
    cube.rotate_y(0.6 * delta)
    cube.rotate_z(0.7 * delta)
