@icon("res://addons/tripod_tools/icons/icon_tool_move.svg")
@tool
extends BaseComponent

## Component that manipiulates the scale of a target node
class_name ScaleComponent

const NAME = 'ScaleComponent'

const GROUP_NAME = 'scaleable'

static func from_parent(node:Node3D)->ScaleComponent:
  return node.get_node_or_null(NAME)

func get_group_name()->String:
  return GROUP_NAME

# ------------------------------------------------------------------

const EPSILON = 0.001

## Scale target node. Uses parent if undefined
@export var scale_target:Node3D: set = set_scale_target

## Minimum scale value
@export_range(0.1, 5.0, 0.01, "or greater") var scale_min:float = 0.2: set = set_scale_min

## Maximum scale value
@export_range(0.1, 5.0, 0.01, "or greater") var scale_max:float = 3.0: set = set_scale_max

## Scale speed
@export var scale_speed = 0.5

## Animate scale
@export var scale_animate:bool = true

## Scale direction
@export var scale_dir:Global.BEAM_MODE = Global.BEAM_MODE.SHRINK

## update scale during process
@export var scaling:bool = false: set = set_scaling

## the scale pivot point
@export var scale_pivot:Node3D

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

signal scale_max_reached()

signal scale_min_reached()

signal scale_start()

signal scale_stop()

func set_scale_target(n:Node3D)->void:
  scale_target = n
  if Engine.is_editor_hint():
    _target = scale_target if scale_target else get_parent()
    set_scale_current(_target.scale.x)

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
    scale_stop.emit()
    return
  if scale_dir == Global.BEAM_MODE.SHRINK and _scale_time > 0.0 \
    or scale_dir == Global.BEAM_MODE.GROW and _scale_time < 1.0:
      scaling = v
      scale_start.emit()

func _ready():
  super._ready()
  # initialize current scale with scale of parent
  _target.ready.connect(func(): set_scale_current(_target.scale.x))

func _process(delta):
  if scaling:
    var dir:float = 1.0 if scale_dir == Global.BEAM_MODE.GROW else -1.0
    if scale_animate:
      update_scale_time(_scale_time + delta * scale_speed * dir)
    else:
      update_scale_time(1.0 if dir > 0.0 else 0.0)

    if _scale_time == 0.0:
      scaling = false
      scale_min_reached.emit()
    elif _scale_time == 1.0:
      scaling = false
      scale_max_reached.emit()

  # special case for preview in editor
  if !scale_current:
    return

  if !Engine.is_editor_hint() or preview:
    var t0:Vector3
    var p0:Vector3

    # check if the player is inside the scaled target
    if _target is Area3D and _target.overlaps_body(%player):
      # get local coordinates of player before scaling so that we can
      # move the player to the "same" position afterwards
      p0 = _target.to_local(%player.global_position)

    if scale_pivot:
      # get global coordinates of pivot before scaling so that we can
      # move the map in place to make it look like it scaled from the pivot
      t0 = scale_pivot.global_position

    # actually scale the target
    _target.scale = Vector3.ONE * scale_current

    # move the map so that the pivot stays constant in world space
    if scale_pivot:
      var d1 = _target.global_position - scale_pivot.global_position
      _target.global_position = d1 + t0

    # move the player back to the same position
    if p0:
      %player.global_position = _target.to_global(p0)
