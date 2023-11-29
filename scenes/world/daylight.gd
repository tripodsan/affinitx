extends AnimationPlayer


func _enter_tree():
  Global.daytime_change.connect(_on_daytime_change)

func _exit_tree():
  Global.daytime_change.disconnect(_on_daytime_change)

func _on_daytime_change():
  if Global.is_day:
    play_backwards('night')
  else:
    play('night')
