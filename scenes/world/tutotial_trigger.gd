@icon("res://addons/ply/icons/plugin.svg")
@tool
extends Node3D
class_name HintPoint

## Text to display for hint
@export var hint_text:String

## Delay in seconds after which the tutorial is shown
@export_range(0.0, 10.0, 0.1, 'suffix:s') var delay:float = 0

@export var enabled:bool = true

@export var disable_action:String

@export var enable_event:Global.GAME_EVENT = Global.GAME_EVENT.NONE

@export var disable_event:Global.GAME_EVENT = Global.GAME_EVENT.NONE

@export var enable_trigger:Trigger

@export var disable_trigger:Trigger

@onready var timer:Timer = $Timer

func _ready():
  if Engine.is_editor_hint():
    $gizmo.visible = true
    $gizmo.mesh.text = name.to_camel_case()
  else:
    $gizmo.visible = false
    Global.game_event.connect(_on_game_event)
    timer.wait_time = delay
    timer.timeout.connect(_on_timer_timeout)
    if enable_trigger:
      enable_trigger.activate.connect(activate)
    if disable_trigger:
      disable_trigger.deactivate.connect(deactivate)

func _unhandled_input(event):
  if disable_action && event.is_action_pressed(disable_action):
    deactivate()

func activate():
  if enabled:
    if delay:
      timer.start()
    else:
      Global.show_hint.emit(hint_text)

func deactivate():
  timer.stop()
  if enabled:
    enabled = false
    Global.hide_hint.emit(hint_text)

func _on_timer_timeout():
  Global.show_hint.emit(hint_text)

func _on_game_event(evt:Global.GAME_EVENT):
  if enable_event == evt:
    activate()
  if disable_event == evt:
    deactivate()
