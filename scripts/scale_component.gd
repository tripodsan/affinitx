@tool
extends Node

## Component that manipiulates the scale of a target node
class_name ScaleComponent

const NAME = 'ScaleComponent'

const GROUP_NAME = 'scaleable'

const EPSILON = 0.001

static func from_parent(node:Node3D)->ScaleComponent:
  return node.get_node_or_null(NAME)

## Scale target node. Uses parent if undefined
@export var scale_target:Node3D

## Minimum scale value
@export_range(0.1, 5.0, 0.1, "or greater") var scale_min:float = 0.2: set = set_scale_min

## Maximum scale value
@export_range(0.1, 5.0, 0.1, "or greater") var scale_max:float = 3.0: set = set_scale_max

## Scale speed
@export var scale_speed = 0.5

## Animate scale
@export var scale_animate:bool = true

## Scale direction
@export var scale_dir:Utils.BEAM_MODE = Utils.BEAM_MODE.SHRINK

## update scale during process
@export var scaling:bool = false: set = set_scaling

@export_group('Scale Preview')

## preview scale in editor
@export var preview:bool = false

## Current Scale Value
@export_range(0.1, 5.0, 0.0001, 'or_greater') var scale_current:float = 1.0: set = set_scale_current

## scale time [0,1] used for interpolation between scale_min and scale_max
@export_range(0.0, 1.0, 0.0001) var scale_time = 0.0: set = set_scale_time, get = get_scale_time
var _scale_time:float = 0.0

## scale ration used for transformation
var _scale_ratio:float

@onready var _target:Node3D = scale_target if scale_target else get_parent()

func set_scale_max(v:float):
  if v >= scale_min:
    scale_max = v
    set_scale_current(scale_current)

func set_scale_min(v:float):
  if v <= scale_max:
    scale_min = v
    set_scale_current(scale_current)

func set_scale_current(v:float):
  scale_current = clamp(v, scale_min, scale_max)
  _scale_ratio = scale_max / scale_min
  _scale_time = log(scale_current/scale_min) / log(_scale_ratio)

func get_scale_time():
  return _scale_time

func set_scale_time(v:float):
  # only recalc current in editor, otherwise it messes up initial values
  _scale_time = clamp(v, 0.0, 1.0)
  if preview and Engine.is_editor_hint():
    update_scale_time(v)

func update_scale_time(v:float):
  _scale_time = clamp(v, 0.0, 1.0)
  scale_current = scale_min * pow(_scale_ratio, _scale_time)

func set_scaling(v:bool):
  if v == scaling:
    return
  if !v:
    scaling = v
    return
  if scale_dir == Utils.BEAM_MODE.SHRINK and _scale_time > 0.0 \
    or scale_dir == Utils.BEAM_MODE.GROW and _scale_time < 1.0:
      scaling = v

func _ready():
  get_parent().add_to_group(GROUP_NAME)
  # initialize current scale with scale of parent
  _target.ready.connect(func(): set_scale_current(_target.scale.x))

func _process(delta):
  if scaling:
    if scale_animate:
      update_scale_time(_scale_time + delta * scale_speed * scale_dir)
      if _scale_time <= 0.0 or _scale_time >= 1.0:
        scaling = false
    else:
      update_scale_time(1.0 if scale_dir > 0 else 0.0)
      scaling = false

  # special case for preview in editor
  if !scale_current:
    return

  if !Engine.is_editor_hint() or preview:
    _target.scale = Vector3.ONE * scale_current
