@tool
extends Node3D

class_name ItemStorage

@export var preview:bool = true

@export var rotation_speed:float = 1

@onready var display = $display

@onready var item:Node3D = $display/item

func _process(delta):
  if preview || !Engine.is_editor_hint():
    display.rotate_y(rotation_speed * delta)
  else:
    display.rotation.y = 0

func get_item()->Node3D:
  return item

func pick_item(discard:bool = false)->Node3D:
  if !item:
    return null
  display.remove_child(item)
  var ret = item
  if discard:
    item.queue_free()
  item = null
  return ret
