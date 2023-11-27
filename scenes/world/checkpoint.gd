@tool
extends Node3D
class_name Checkpoint

@export_placeholder('Untitled') var title:String

@export var teleport_player:bool = false: set = set_teleport_player

@export var preview:bool = false

@export var marker:bool = true

@export var checked:bool = false

@export var rotate_max:float = 20.0

@export var rotate_min:float = 2.0

@onready var rotate_target = $marker/crystal
@onready var laser_component:LaserComponent = $LaserComponent

var rotate_speed:float

var _laser_on:bool

func _ready():
  if !Engine.is_editor_hint():
    Global.register_checkpoint(self)
  $area.body_entered.connect(_on_body_entered)
  $collission.disabled = !marker
  $marker.visible = marker
  laser_component.laser_hit_on.connect(func (): _laser_on = true)
  laser_component.laser_hit_off.connect(func (): _laser_on = false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if Engine.is_editor_hint() and !preview:
    return

  if marker and checked:
    if _laser_on:
      rotate_speed = rotate_max

    rotate_target.rotate_y(rotate_speed * delta)
    rotate_speed = lerp(rotate_speed, rotate_min, 0.02)

func _on_body_entered(body:Node3D):
  if body is Player and !checked:
    checked = true
    rotate_speed = rotate_max
    Global.checkpoint_reached(self)

func set_teleport_player(v:bool)->void:
    if !v or !%player: return
    var delta = Vector3.ZERO
    if marker:
      delta = Vector3(0, 0, 1)
    %player.position = position + delta
    %player.rotation.y = 0
    %player.orient_towards(Vector3.FORWARD, 0.5)
    if !Engine.is_editor_hint():
      Global.console.log_info('teleported player to "%s"' % title)
