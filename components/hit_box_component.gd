@icon("res://addons/tripod_tools/icons/icon_skull.svg")
@tool
extends Node

## Component that deals damange to the player
class_name HitBoxComponent

const NAME = 'HitBoxComponent'

const GROUP_NAME = 'hitbox'

static func from_parent(node:Node3D)->HitBoxComponent:
  return node.get_node_or_null(NAME)

func get_group_name()->String:
  return GROUP_NAME
