extends CanvasLayer

@onready var animation_player = $AnimationPlayer

@onready var default_color:Color = $disolve_rect.color

@export_color_no_alpha var game_end_color:Color

func change_scene(target:String, speed:float = 1.0, game_end:bool = false)->void:
  if game_end:
    $disolve_rect.color = game_end_color
  else:
    $disolve_rect.color = default_color
  animation_player.play('fadeout', -1, speed)
  await animation_player.animation_finished
  get_tree().change_scene_to_file(target)
  animation_player.play('fadein', -1, speed)
