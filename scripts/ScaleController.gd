@icon("res://addons/ply/icons/icon_tool_move.svg")
@tool
extends Node3D
class_name ScaleController

@export var scales: Array[float] = [1.0, 0.3]

@export var scale_target_idx:int = 0:
  set = set_scale_target_idx

@export var scale_animate:bool = false

@export var current_pivot:Node3D

var _scale_current_idx:int = 0
var _scale_current:float = 1.0
var _scale_target:float = 1.0

const EPSILON = 0.001

@onready var _chunk:Area3D = get_parent()

func set_scale_target_idx(idx:int):
  scale_target_idx = idx
  _scale_target = scales[idx]

func _ready():
  pass


func _input(event):
  if event.is_action_pressed("toggle_scale"):
    scale_target_idx = (scale_target_idx + 1) % scales.size()

func _process(delta):
  if _scale_target == _scale_current:
    return

  # todo: animate
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

