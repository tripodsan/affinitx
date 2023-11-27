@icon("res://addons/tripod_tools/icons/icon_tool_laser.svg")
@tool
extends BaseComponent

## Component that manipiulates the scale of a target node
class_name LaserComponent

const NAME = 'LaserComponent'

## hack to get laser hits
const GROUP_NAME = ScaleComponent.GROUP_NAME

static func from_parent(node:Node3D)->LaserComponent:
  return node.get_node_or_null(NAME)

func get_group_name()->String:
  return GROUP_NAME

## laser target node. Uses parent if undefined
@export var laser_target:Node3D

@onready var target:Node3D = laser_target if laser_target else get_parent()

signal laser_hit_on()
signal laser_hit_off()

func laser_hit(v:bool):
  if v:
    laser_hit_on.emit()
  else:
    laser_hit_off.emit()
