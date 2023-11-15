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

signal hit_target_on(target:Node3D)
signal hit_target_off(target:Node3D)

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

  force_raycast_update()

  var new_target = get_collider();
  if new_target and new_target.is_in_group(ScaleComponent.GROUP_NAME):
    update_target(new_target, fire)
  else:
    update_target(null, fire)

  if target:
    var cast_point:Vector3 = to_local(get_collision_point())
    beam.mesh.height = cast_point.y
    beam.position.y = cast_point.y/2
    particles.position.y = cast_point.y
  else:
    particles.emitting = false

func update_target(v:Node3D, f:bool):
  # if nothing changed: return
  if v == target and f == was_fire:
    return

  # if the old target was active, turn off
  if v != target and target and was_fire:
    hit_target_off.emit(target)

  # if the same target is no longer active, turn off
  if v == target and target and !fire:
    hit_target_off.emit(target)

  # if the new target is active, turn on
  if v and fire:
    hit_target_on.emit(v)

  was_fire = fire;
  target = v;
