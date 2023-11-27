extends Control

@onready var intro_animation = $intro_animation

@onready var start = %start

signal menu_start()

func _ready():
  if Global.SKIP_TITLE:
    _on_start_pressed()
    return

  start.grab_focus()
  get_viewport().gui_disable_input = true
  intro_animation.animation_finished.connect(_on_intro_finished)
  if !Global.DEBUG:
    await get_tree().create_timer(1).timeout
  intro_animation.play("scale")

func _on_intro_finished(_anim):
  get_viewport().gui_disable_input = false

func _on_start_pressed():
  Global.start_game()

func _on_quit_pressed():
  Global.quit_game()

func _on_settings_pressed():
  pass # Replace with function body.
