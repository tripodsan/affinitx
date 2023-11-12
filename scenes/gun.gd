extends Node3D

class_name Gun

@onready var laser:Laser = $mesh/laser

func _ready():
  aim(false)
  fire(false)

func aim(v: bool):
  laser.on = v

func fire(v: bool):
  laser.fire = v
