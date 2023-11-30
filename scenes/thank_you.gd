extends Control

var credits_shown:bool = false

func _input(event:InputEvent):
  if event.is_pressed():
    if not credits_shown:
      credits_shown = true
      $AnimationPlayer.play("credits")
    else:
      Global.show_title_screen()

