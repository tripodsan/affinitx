@icon("res://addons/ply/icons/plugin.svg")
@tool
extends Node3D

class_name TutorialTrigger

## Tutorial Label to display when player enters the area
@export_node_path("Label") var label_path
@onready var label:Label = null if !label_path else get_node(label_path)

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
    if label:
      $gizmo.mesh.text = label.name
    pass
  else:
    $gizmo.visible = false
    Global.game_event.connect(_on_game_event)
    timer.wait_time = delay
    timer.timeout.connect(_on_timer_timeout)
    if enable_trigger:
      enable_trigger.activate.connect(activate)
    if disable_trigger:
      disable_trigger.deactivate.connect(deactivate)

func _input(event):
  if disable_action && event.is_action_pressed(disable_action):
    deactivate()

func activate():
  if enabled:
    enabled = false
    if delay:
      timer.start()
    else:
      Global.show_hint.emit(label)

func deactivate():
  enabled = false
  timer.stop()
  Global.show_hint.emit(null)

func _on_timer_timeout():
  Global.show_hint.emit(label)

func _on_game_event(evt:Global.GAME_EVENT):
  if enable_event == evt:
    activate()
  if disable_event == evt:
    deactivate()
