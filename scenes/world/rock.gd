extends Node3D

func _ready():
  var s = randf_range(0.9, 1.1)
  scale = Vector3.ONE * s
  $root.rotate_x(randf_range(0, TAU))
  $root.rotate_y(randf_range(0, TAU))
  $root.rotate_z(randf_range(0, TAU))
