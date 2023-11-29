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

## the collision shape (box) to adjust when scaling ridgid modies
@export var collision_shape:CollisionShape3D: set = set_collision_shape

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

## the current scale origin in global coords
var current_scale_origin:Vector3

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

## collision box
var _collision_box:BoxShape3D

## initial size of collision box
var _collision_box_size:Vector3

@onready var _target:Node3D = scale_target if scale_target else get_parent()

signal scale_max_reached()

signal scale_min_reached()

signal scale_changed()

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
  if _scale_time == 0:
    scale_current = scale_min
  elif _scale_time == 1:
    scale_current = scale_max
  else:
    scale_current = scale_min * pow(_scale_ratio, _scale_time)

func set_scale_origin(v:Vector3):
  current_scale_origin = v

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

func set_collision_shape(v:CollisionShape3D):
  collision_shape = v
  _collision_box = collision_shape.shape if collision_shape and collision_shape.shape is BoxShape3D else null
  update_configuration_warnings()

func _get_configuration_warnings():
  if collision_shape and !_collision_box:
    return ['can only adjust size of a BoxShape3D for collision box']
  if _collision_box and !_collision_box.resource_local_to_scene:
    return ['BoxShape3D is not local to scene.']


func _ready():
  super._ready()
  # initialize current scale with scale of parent
  _target.ready.connect(func(): set_scale_current(_target.scale.x))
  if _collision_box:
    _collision_box_size = _collision_box.size

func _process(delta):
  var force_update:bool = false

  if scaling:
    var dir:float = 1.0 if scale_dir == Global.BEAM_MODE.GROW else -1.0
    if scale_animate:
      update_scale_time(_scale_time + delta * scale_speed * dir)
    else:
      update_scale_time(1.0 if dir > 0.0 else 0.0)

    if _scale_time == 0.0:
      scaling = false
      force_update = true
      scale_min_reached.emit()
    elif _scale_time == 1.0:
      scaling = false
      force_update = true
      scale_max_reached.emit()

  # special case for preview in editor
  if !scale_current:
    return

  var scale_ratio = scale_current / _target.scale.x
  if not force_update and abs(1.0 - scale_ratio) < EPSILON:
    return

  if !Engine.is_editor_hint() or preview:
    var t0:Vector3
    var p0:Vector3

    # check if the player is inside the scaled target
    if _target is Area3D and _target.overlaps_body(%player):
      # get local coordinates of player before scaling so that we can
      # move the player to the "same" position afterwards
      p0 = _target.to_local(%player.global_position)

    # override the scale origin if a pivot is defined
    if scale_pivot:
      current_scale_origin = scale_pivot.global_position
    # remember the scale origin in local coords
    t0 = _target.to_local(current_scale_origin)

    # actually scale the target
    _target.scale = Vector3.ONE * scale_current

    # apply a translation to move the scale origin back in place
    var origin_shift:Vector3
    if current_scale_origin:
      origin_shift = current_scale_origin - _target.to_global(t0)
      _target.global_position += origin_shift

    # move the player back to the same position
    if p0:
      %player.global_position = _target.to_global(p0)

    # adjust collision box
    if _collision_box and !Engine.is_editor_hint():
      _collision_box.size = _collision_box_size * scale_current
      collision_shape.global_position += origin_shift

    if !Engine.is_editor_hint():
      # fix rigid bodies
      Utils.fix_rigid_body_scale(_target, scale_current, current_scale_origin, scale_ratio)

      # notify scale changed
      scale_changed.emit()
