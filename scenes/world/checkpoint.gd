@tool
extends Node3D
class_name Checkpoint

@export_placeholder('Untitled') var title:String

@export var teleport_player:bool = false:
  set(v):
    if v and %player:
      %player.position = position
      Global.console.log_info('teleported player to "%s"' % title)

@export var preview:bool = false

@export var marker:bool = true

@export var checked:bool = false

@export var rotate_max:float = 20.0

@export var rotate_min:float = 2.0

var rotate_speed:float

func _ready():
  Global.register_checkpoint(self)
  $area.body_entered.connect(_on_body_entered)
  $marker.visible = marker

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if Engine.is_editor_hint() and !preview:
    return

  if marker and checked:
    $marker.rotate_y(rotate_speed * delta)
    rotate_speed = lerp(rotate_speed, rotate_min, 0.02)

func _on_body_entered(body:Node3D):
  if body is Player and !checked:
    checked = true
    rotate_speed = rotate_max
    Global.checkpoint_reached(self)
