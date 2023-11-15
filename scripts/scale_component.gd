extends Node

class_name ScaleComponent

const NAME = 'ScaleComponent'

const GROUP_NAME = 'scaleable'

const EPSILON = 0.001

static func from_parent(node:Node3D)->ScaleComponent:
  return node.get_node_or_null(NAME)

@export var scale_target:Node3D

@export var scales: Array[float] = [0.2, 1.0]

@export var scale_duration = 1.0

@export var scale_animate:bool = true

@export var scale_target_idx:int = 1:
  set = set_scale_target_idx

var _scale_current_idx:int = 0
var _scale_current:float = 1.0
var _scale_start:float = 1.0
var _scale_target:float = 1.0
var _scale_time:float = 0.0

@onready var _chunk:Node3D = scale_target if scale_target else get_parent()

var on:bool = false

func _ready():
  assert(get_name() == NAME)
  get_parent().add_to_group(GROUP_NAME)

func set_scale_target_idx(idx:int):
  if scale_target_idx != idx:
    scale_target_idx = idx
    _scale_start = _scale_current
    _scale_target = scales[idx]
    _scale_time = 0

func shrink():
  if scale_target_idx > 0:
    scale_target_idx -= 1
  on = true

func grow():
  if scale_target_idx < scales.size():
    scale_target_idx += 1
  on = true

func off():
  on = false

func _process(delta):
  if _scale_target == _scale_current or !on:
    return

  if scale_animate:
    _scale_time += delta * _scale_current
    if (_scale_time >= scale_duration):
      _scale_current = _scale_target
    else:
      _scale_current = lerp(_scale_start, _scale_target, _scale_time / scale_duration)
  else:
    _scale_current = _scale_target

  # actually scale the world
  _chunk.scale = Vector3.ONE * _scale_current
