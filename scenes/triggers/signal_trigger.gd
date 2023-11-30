@tool
extends Trigger
class_name SignalTrigger

@export var emit_activate:bool = true
@export var emit_deactivate:bool = false

func _on_external_signal():
  if emit_activate:
    activate.emit()
  if emit_deactivate:
    deactivate.emit()
