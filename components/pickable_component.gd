@icon("res://addons/tripod_tools/icons/icon_box.svg")
@tool
extends BaseComponent

## Component that allows to pick objects
class_name PickableComponent

const NAME = 'PickableComponent'

const GROUP_NAME = 'pickable'

## pick target node. Uses parent if undefined
@export var pick_target:Node3D

@export var scale_component:ScaleComponent

@export var max_scale:float = 0.4

@export var highlight_mesh:VisualInstance3D

@onready var target:Node3D = pick_target if pick_target else get_parent()

var highlight_enabled:bool = false

var can_pickup:bool = false
var was_pickup:bool = false

signal picked_up()
signal dropped()

static func from_parent(node:Node3D)->PickableComponent:
  return node.get_node_or_null(NAME)

func _ready():
  if scale_component:
    scale_component.scale_changed.connect(_recalc)
  _recalc()

func get_group_name()->String:
  return GROUP_NAME

func enable_highlight(v:bool):
  highlight_enabled = v
  _update_highlight()

func _recalc():
  can_pickup = !scale_component or scale_component.scale_current < max_scale
  if can_pickup == was_pickup:
    return
  was_pickup = can_pickup
  _update_highlight()

func _update_highlight():
  if is_instance_valid(highlight_mesh):
    Utils.set_layer_mask_value_deep(highlight_mesh, 2, can_pickup and highlight_enabled)

func pickup():
  if can_pickup:
    enable_highlight(false)
    picked_up.emit()

func drop():
  dropped.emit()
