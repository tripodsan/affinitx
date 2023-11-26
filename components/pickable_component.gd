@icon("res://addons/tripod_tools/icons/icon_box.svg")
@tool
extends BaseComponent

## Component that allows to pick objects
class_name PickableComponent

const NAME = 'PickableComponent'

const GROUP_NAME = 'pickable'

@export var scale_component:ScaleComponent

@export var max_scale:float = 0.4

@export var highlight_mesh:VisualInstance3D

static func from_parent(node:Node3D)->PickableComponent:
  return node.get_node_or_null(NAME)

func get_group_name()->String:
  return GROUP_NAME

func can_pickup():
  return !scale_component or scale_component.scale_current < max_scale

func enable_highlight(v:bool):
  if is_instance_valid(highlight_mesh):
    Utils.set_layer_mask_value_deep(highlight_mesh, 2, v)


