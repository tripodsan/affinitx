extends RigidBody3D

@onready var collision = $collision
@onready var pickable_component:PickableComponent = PickableComponent.from_parent(self)

signal hitbox_entered(hitbox:HitBoxComponent)

func _ready():
  top_level = true
  pickable_component.picked_up.connect(_on_picked_up)
  pickable_component.dropped.connect(_on_dropped)

func _on_picked_up():
  # reset all rotation when picked up
  collision.position = Vector3.ZERO
  collision.rotation = Vector3.ZERO

func _on_dropped():
  pass

func _on_body_entered(node:Node3D):
  var hcmp:HitBoxComponent = HitBoxComponent.from_parent(node)
  if hcmp:
    hcmp.hit_by_npc(self)
    hitbox_entered.emit(hcmp)
