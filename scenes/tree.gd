extends StaticBody3D


func _ready():
  position.y += randf_range(-0.1, 0)
  rotate_y(randf_range(0, TAU))
  $leaves1.position.y += randf_range(-0.1, 0.1)
  $leaves2.position.y += randf_range(0, 0.1)
