@tool
extends Node3D
class_name SoundQueue3D

@export_range(0, 10, 1) var count:int = 1

@export var loop:bool = false

@export_range(0.1, 10, 0.01, 'suffix:s') var duration:float = 0.1

@export var preview:bool:
  set(v):
    if loop:
      preview = v
    else:
      play()

var playing:bool = false

var _players:Array[AudioStreamPlayer3D]

var _next:int = 0

var _time:float = 0.0

func _ready():
  if _get_configuration_warnings().size():
    return
  var p:AudioStreamPlayer3D = get_child(0)
  _players.push_back(p)
  for i in count:
    var n:AudioStreamPlayer3D = p.duplicate()
    add_child(n)
    _players.push_back(n)

func _process(delta):
  if !loop or !playing:
    return
  if Engine.is_editor_hint() and not preview:
    return
  _time += delta
  if _time > duration:
    _time -= duration
    _play_next()

func _get_configuration_warnings():
  if get_child_count() == 0 or !get_child(0) is AudioStreamPlayer3D:
    return ['need a AudioStreamPlayer3D child']
  return []

func play():
  if loop:
    if not playing:
      playing = true
      _time = 0.0
      _play_next()
  else:
    _play_next()

func stop():
  playing = false

func _play_next():
  playing = true
  if _next < _players.size() and !_players[_next].playing:
    _players[_next].play()
    _next = (_next + 1) % _players.size()
