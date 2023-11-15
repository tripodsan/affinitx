extends Node3D

func _ready():
  $root.rotate_x(randf_range(0, TAU))
  $root.rotate_y(randf_range(0, TAU))
  $root.rotate_z(randf_range(0, TAU))
