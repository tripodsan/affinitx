extends Node3D

class_name Gun

@onready var laser:Laser = $mesh/laser

func _ready():
  set_aim(false)
  fire(false)

func set_aim(v:bool):
  laser.on = v

func fire(v: bool):
  laser.fire = v
