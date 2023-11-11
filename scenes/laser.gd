extends RayCast3D

@onready var beam:MeshInstance3D = $beam
@onready var particles:GPUParticles3D = $end_particles
@onready var beam_particles:GPUParticles3D = $beam_particles

func _ready():
  particles.emitting = false

func _process(delta):
  if !is_visible_in_tree():
    particles.emitting = false
    return
  particles.emitting = true
  force_raycast_update()

  if is_colliding():
    var cast_point:Vector3 = to_local(get_collision_point())
    beam.mesh.height = cast_point.y
    beam.position.y = cast_point.y/2
    particles.position.y = cast_point.y

    #beam_particles.lifetime = 1;
    #beam_particles.amount = 10;
    beam_particles.amount = abs(cast_point.y) * 20
    beam_particles.lifetime = abs(cast_point.y) / beam_particles.process_material.initial_velocity_min
