extends StaticBody3D

var _player:CharacterBody3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if _player:
    _player.velocity.x = 10;
  pass


func _on_area_3d_body_entered(body):
  if body == %player:
    _player = body


func _on_area_3d_body_exited(body):
  if body == %player:
    _player = null
