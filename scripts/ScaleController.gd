@icon("res://addons/ply/icons/icon_tool_move.svg")
@tool
extends Node3D
class_name ScaleController

@export var scales: Array[float] = [1.0, 0.2]

@export var scale_target_idx:int = 0:
  set = set_scale_target_idx

@export var scale_animate:bool = false

@export var current_pivot:Node3D

var _scale_current_idx:int = 0
var _scale_current:float = 1.0
var _scale_start:float = 1.0
var _scale_target:float = 1.0
var _scale_time:float = 0.0

const SCALE_DURATION = 1.0

const EPSILON = 0.001

@onready var _chunk:Area3D = get_parent()

func set_scale_target_idx(idx:int):
  if scale_target_idx != idx:
    scale_target_idx = idx
    _scale_start = _scale_current
    _scale_target = scales[idx]
    _scale_time = 0

func _ready():
  pass


func _input(event):
  if event.is_action_pressed("toggle_scale"):
    scale_target_idx = (scale_target_idx + 1) % scales.size()

func _process(delta):
  if _scale_target == _scale_current:
    return

  if scale_animate:
    _scale_time += delta * _scale_current
    if (_scale_time >= SCALE_DURATION):
      _scale_current = _scale_target
    else:
      _scale_current = lerp(_scale_start, _scale_target, _scale_time / SCALE_DURATION)
  else:
    _scale_current = _scale_target

  # get local coordinates of player before scaling so that we can
  # move the player to the "same" position afterwards
  var p0 = to_local(%player.global_position)

  # get global coordinates of pivot before scaling so that we can
  # move the map in place to make it look like it scaled from the pivot
  var t0 = current_pivot.global_position

  # actually scale the world
  _chunk.scale = Vector3.ONE * _scale_current

  # move the map so that the pivot stays constant in world space
  var d1 = _chunk.global_position - current_pivot.global_position
  _chunk.global_position = d1 + t0

  # move the player in place if in this chunk
  if not Engine.is_editor_hint() and _chunk.overlaps_body(%player):
    %player.global_position = to_global(p0)

