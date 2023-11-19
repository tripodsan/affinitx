extends Node3D

class_name Gun

@onready var laser:Laser = $mesh/laser

@export var enabled:bool = true

var beam_mode:Global.BEAM_MODE = Global.BEAM_MODE.SHRINK

func _ready():
  set_process_unhandled_input(enabled)
  set_aim(false)
  fire(false)
  laser.hit_target_on.connect(_on_laser_hit_target_on)
  laser.hit_target_off.connect(_on_laser_hit_target_off)

func _unhandled_input(event):
  if visible and event.is_action_pressed('toggle_mode'):
    beam_mode = ((beam_mode + 1) % 2) as Global.BEAM_MODE
    Global.console.log_info('set beam mode to %s' % Global.BEAM_MODE.keys()[beam_mode])
    Global.weapon_change.emit(self)

func set_aim(v:bool):
  laser.on = v

func fire(v: bool):
  laser.fire = v

func _on_laser_hit_target_on(target:Node3D):
  var scmp = ScaleComponent.from_parent(target)
  if !scmp: return
  scmp.scale_dir = beam_mode
  scmp.scaling = true

func _on_laser_hit_target_off(target:Node3D):
  var scmp = ScaleComponent.from_parent(target)
  if !scmp: return
  scmp.scaling = false
