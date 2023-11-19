@tool
extends Node
class_name BaseComponent

func _ready():
  get_parent().add_to_group(get_group_name())

func get_group_name()->String:
  assert(false, 'abstractt method error')
  return ''
