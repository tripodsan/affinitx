@tool
extends StaticBody3D

class_name Pedestal

@onready var audio:AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var cube = $cube_container/cube

@export var preview:bool = false

@export var enabled:bool = true: set = set_enabled

var mute:bool = false: set = set_mute

func set_enabled(v:bool):
  enabled = v
  _update()

func set_mute(v:bool):
  mute = v
  _update()

func _ready():
  _update()

func _update():
  if !audio: return
  var play = enabled and not mute
  if play and not audio.playing:
    audio.play()
  elif !play and audio.playing:
    audio.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if not enabled: return

  if preview or not Engine.is_editor_hint():
    cube.rotate_x(0.5 * delta)
    cube.rotate_y(0.6 * delta)
    cube.rotate_z(0.7 * delta)
