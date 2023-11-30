extends RigidBody3D
class_name Tower

@onready var collision:CollisionShape3D = $collision
@onready var pickable_component:PickableComponent = PickableComponent.from_parent(self)
@onready var scale_component:ScaleComponent = ScaleComponent.from_parent(self)

@onready var animation_player:AnimationPlayer = $AnimationPlayer

@onready var drop_position:Vector3 = collision.position

var _locked:bool = false

var doors_open:bool = false

func _ready():
  top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)

func _on_picked_up():
  collision_layer &= ~32
  collision.position = Vector3.ZERO
  collision.rotation = Vector3.ZERO

func _on_dropped():
  collision_layer |= 32
  collision.position = drop_position
  global_position.y -= 0.5

func lock():
  _locked = true
  gravity_scale = 0 # TODO: find better way?
  collision.disabled = true

func grow():
  freeze = true
  scale_component.scale_max_reached.connect(_on_tower_grown)
  scale_component.set_scaling(true)

func _on_tower_grown():
  Global.player_event(Global.GAME_EVENT.TOWER_ACTIVATED)
  lock()

func _on_door_area_body_entered(body):
  if body is Player and _locked and !doors_open:
    doors_open = true
    animation_player.play("open")

func _on_inside_area_body_entered(body):
  if body is Player and _locked:
    Global.player_event(Global.GAME_EVENT.TOWER_ENTERED)


