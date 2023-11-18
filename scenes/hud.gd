extends Control

@onready var gun_ui_grow = $footer/grow
@onready var gun_ui_shrink = $footer/shrink

func _ready():
  Global.weapon_change.connect(_on_weapon_change)

func _on_weapon_change(gun:Gun):
  if !gun:
    gun_ui_grow.visible = false
    gun_ui_shrink.visible = false
    return

  gun_ui_grow.visible = gun.beam_mode == Utils.BEAM_MODE.GROW
  gun_ui_shrink.visible = gun.beam_mode == Utils.BEAM_MODE.SHRINK
