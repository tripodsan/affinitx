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
  var scale_target = SCALE_BIG if world_is_big else SCALE_NORMAL
  var new_scale = lerp(scale_factor, scale_target, delta * 2.0)
  if abs(new_scale - scale_target) < 0.01:
    new_scale = scale_target
  
  if new_scale != scale_factor:
    scale_factor = new_scale  
    var player:Node3D = get_parent().get_node('player')
    
    # get local coordinates of player before scaling so that we can 
    # move the player to the "same" position afterwards
    var p0 = to_local(player.global_position)
    
    # get global caoordinates of pivot before scaling so that we can
    # move the map in place to make it look like it scaled from the pivot
    var t0 = $pivot.global_position
    
    # actually scale the world
    scale = Vector3.ONE * scale_factor
    
    # move the map so that the pivot stays constant in world space
    var d1 = global_position - $pivot.global_position
    global_position = d1 + t0
    
    # move the player in place if in this map
    if player.position.z > 0:
      player.global_position = to_global(p0)
        
    
