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
#  set(v):
#    if v and !on and particles:
#      particles.restart()
#    on = v

@export var on:bool = false

var time:float = 0

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

  if is_colliding():
    var cast_point:Vector3 = to_local(get_collision_point())
    beam.mesh.height = cast_point.y
    beam.position.y = cast_point.y/2
    particles.position.y = cast_point.y
  else:
    particles.emitting = false

    #beam_particles.lifetime = 1;
    #beam_particles.amount = 10;
#    beam_particles.amount = abs(cast_point.y) * 5
#    beam_particles.lifetime = abs(cast_point.y) / beam_particles.process_material.initial_velocity_min
