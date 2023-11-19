@tool
extends Trigger
class_name AreaTrigger

var _area:Area3D

## Body that entered or exited this trigger
var trigger_body:Node3D

func _enter_tree():
  _validate()

func _ready():
  _validate()
  if _area:
    _area.body_entered.connect(_on_body_entered)
    _area.body_exited.connect(_on_body_exited)

func _notification(what):
  if what == NOTIFICATION_CHILD_ORDER_CHANGED:
    _validate()

func _validate()->void:
  _area = null
  for a in get_children():
    if a is Area3D:
      _area = a
      break
  update_configuration_warnings()

func _get_configuration_warnings():
  if !_area:
    return ['Missing Area3D child node']

func _on_body_entered(n: Node3D):
  if n is Player:
    trigger_body = n
    activate.emit()

func _on_body_exited(n: Node3D):
  if n is Player:
    trigger_body = n
    deactivate.emit()
