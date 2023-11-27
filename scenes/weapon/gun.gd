extends Node3D

class_name Gun

@onready var laser:Laser = $mesh/laser

@export var enabled:bool = true

var target_lock_enabled:bool = true
var target_locked:bool
var target_scmp:ScaleComponent
var target_pcmp:PickableComponent

var beam_mode:Global.BEAM_MODE = Global.BEAM_MODE.SHRINK

func _ready():
  set_process_unhandled_input(enabled)
  set_aim(false)
  fire(false)
  laser.hit_target_on.connect(_on_laser_hit_target_on)
  laser.hit_target_off.connect(_on_laser_hit_target_off)
  laser.aim_target_on.connect(_on_laser_aim_target_on)
  laser.aim_target_off.connect(_on_laser_aim_target_off)

func _unhandled_input(event):
  if visible and event.is_action_pressed('toggle_mode'):
    beam_mode = ((beam_mode + 1) % 2) as Global.BEAM_MODE
    Global.console.log_info('set beam mode to %s' % Global.BEAM_MODE.keys()[beam_mode])
    Global.weapon_change.emit(self)
    if target_scmp:
      target_scmp.scale_dir = beam_mode
      target_scmp.scaling = true

func set_aim(v:bool):
  laser.on = v

func fire(v: bool):
  laser.fire = v

func toggle_target_lock():
  target_lock_enabled = !target_lock_enabled
  Global.console.log_info('set target lock to: %s' % target_lock_enabled)
  Global.target_lock_changed.emit(target_lock_enabled)

func _process(_delta)->void:
  if target_locked:
    look_at(laser.hit_position, Vector3(0, 1,0), true)

func _on_laser_aim_target_on(target:Node3D, _pos:Vector3):
  target_pcmp = PickableComponent.from_parent(target)
  if target_pcmp:
    target_pcmp.enable_highlight(true)

func _on_laser_aim_target_off(_target:Node3D):
  if target_pcmp:
    target_pcmp.enable_highlight(false)
    target_pcmp = null

func _on_laser_hit_target_on(target:Node3D, pos:Vector3):
  var lcmp:LaserComponent = LaserComponent.from_parent(target)
  if lcmp:
    lcmp.laser_hit(true)
  target_scmp = ScaleComponent.from_parent(target)
  if !target_scmp: return
  if target_lock_enabled:
    laser.lock_target()
    target_locked = true

  target_scmp.scale_dir = beam_mode
  target_scmp.set_scale_origin(pos)
  target_scmp.scaling = true

func _on_laser_hit_target_off(target:Node3D):
  var lcmp:LaserComponent = LaserComponent.from_parent(target)
  if lcmp:
    lcmp.laser_hit(false)
  if target_scmp:
    target_locked = false
    target_scmp.scaling = false
    target_scmp = null
