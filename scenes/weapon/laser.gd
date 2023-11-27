@tool
extends RayCast3D

class_name Laser

@onready var beam:MeshInstance3D = $beam
@onready var particles:GPUParticles3D = $end_particles
#@onready var beam_particles:GPUParticles3D = $beam_particles

@export var pulse:bool = true
@export var pulse_speed:float = 10.0
@export var pulse_scale:float = 0.5
@export var pulse_offset:float = 1.0

@export var fire:bool = false

@export var on:bool = false

var time:float = 0

var was_fire:bool = false

var target:Node3D = null

var hit_position:Vector3

var local_hit_position:Vector3

var target_locked:bool = false

signal hit_target_on(target:Node3D, pos:Vector3)
signal hit_target_off(target:Node3D)
signal aim_target_on(target:Node3D, pos:Vector3)
signal aim_target_off(target:Node3D)

func _ready():
  particles.emitting = false

func _process(delta):
  time += delta

  if !is_visible_in_tree():
    particles.emitting = false
    particles.restart()
    return

  $beam.visible = on
  particles.emitting = fire and on
  if !on:
    target_locked = false
    update_target(null, false)
    return

  if pulse and fire:
    var s:float = sin(time * pulse_speed) * pulse_scale + pulse_offset
    beam.scale.x = s
    beam.scale.z = s
  else:
    beam.scale = Vector3.ONE

  var mat:StandardMaterial3D = $beam.get_active_material(0)
  if mat:
    mat.emission_enabled = fire

  if Engine.is_editor_hint():
    return

  if target_locked:
    if fire:
      # recalculate hit position based on potentially new scale of target object
      hit_position = target.to_global(local_hit_position)
      adjust_beam()
      return
    else:
      target_locked = false

  force_raycast_update()

  var new_target = get_collider()
  hit_position = get_collision_point()
  if new_target and new_target.is_in_group(ScaleComponent.GROUP_NAME):
    mat.emission_enabled = true
    update_target(new_target, fire)
  else:
    mat.emission_enabled = fire
    update_target(null, fire)

  if new_target:
    adjust_beam()

  if !target:
    particles.emitting = false

func adjust_beam():
    var pos = to_local(hit_position)
    beam.mesh.height = pos.y
    beam.position.y = pos.y/2
    particles.position.y = pos.y

func update_target(v:Node3D, f:bool):
  # if nothing changed: return
  if v == target and f == was_fire:
    return

  # if the old target was active, turn off
  if v != target and target:
    aim_target_off.emit(target)
    if was_fire:
      hit_target_off.emit(target)

  # if the same target is no longer active, turn off
  if v == target and target and !fire:
    hit_target_off.emit(target)

  # if the new target is valid, emit
  if v:
    aim_target_on.emit(v, hit_position)
    # if the new target is active, turn on
    if  fire:
      hit_target_on.emit(v, hit_position)
      local_hit_position = v.to_local(hit_position)

  was_fire = fire;
  target = v;

func lock_target()->void:
  if !target_locked && target:
    target_locked = true
