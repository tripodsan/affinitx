extends Node3D

class_name Gun

@onready var laser:Laser = $mesh/laser

func _ready():
  set_aim(false)
  fire(false)
  laser.hit_target_on.connect(_on_laser_hit_target_on)
  laser.hit_target_off.connect(_on_laser_hit_target_off)

func set_aim(v:bool):
  laser.on = v

func fire(v: bool):
  laser.fire = v

func _on_laser_hit_target_on(target:Node3D):
  var scmp = ScaleComponent.from_parent(target)
  if !scmp: return
  scmp.shrink()

func _on_laser_hit_target_off(target:Node3D):
  var scmp = ScaleComponent.from_parent(target)
  if !scmp: return
  scmp.off()
