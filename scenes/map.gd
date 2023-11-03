extends Node3D

# scale
const SCALE_NORMAL = 1.0
const SCALE_BIG = 10.0
var world_scale = SCALE_NORMAL
var world_is_big = false
var scale_factor:float = SCALE_NORMAL

func _ready():
  pass # Replace with function body.

func _input(event):
  if event.is_action_pressed("toggle_scale"):
    world_is_big = !world_is_big
  

func _physics_process(delta):
  # handle scale
  scale_factor = lerp(scale_factor, SCALE_BIG if world_is_big else SCALE_NORMAL, delta * 2.0)
  scale = Vector3.ONE * scale_factor
