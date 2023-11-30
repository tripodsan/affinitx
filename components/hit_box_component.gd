@icon("res://addons/tripod_tools/icons/icon_skull.svg")
@tool
extends BaseComponent

## Component that deals damange to the player
class_name HitBoxComponent

const NAME = 'HitBoxComponent'

const GROUP_NAME = 'hitbox'

## death message
@export var message:String = 'died.'

signal player_hit(player:Player)

signal npc_hit(node:Node3D)

static func from_parent(node:Node3D)->HitBoxComponent:
  return node.get_node_or_null(NAME)

func _ready():
  super._ready()

func get_group_name()->String:
  return GROUP_NAME

func hit_by_player(player:Player):
  player_hit.emit(player)

func hit_by_npc(node:Node3D):
  npc_hit.emit(node)
