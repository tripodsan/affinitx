extends StaticBody3D


func _ready():
  rotate_x(randf_range(0, TAU))
  rotate_y(randf_range(0, TAU))
  rotate_z(randf_range(0, TAU))
