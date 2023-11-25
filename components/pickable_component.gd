@icon("res://addons/tripod_tools/icons/icon_box.svg")
@tool
extends BaseComponent

## Component that allows to pick objects
class_name PickableComponent

const NAME = 'PickableComponent'

const GROUP_NAME = 'pickable'

@export var min_scale_condition:ScaleComponent

@export var highlight_mesh:VisualInstance3D

static func from_parent(node:Node3D)->PickableComponent:
  return node.get_node_or_null(NAME)

func get_group_name()->String:
  return GROUP_NAME

func can_pickup():
  return !min_scale_condition or min_scale_condition.scale_time == 0.0

func enable_highlight(v:bool):
  if is_instance_valid(highlight_mesh):
    Utils.set_layer_mask_value_deep(highlight_mesh, 2, v)


