extends Control

@onready var messages = $margin/messages

@onready var initial_font_size:int = theme.get_font_size('default', 'default')

var last_hint:Label

func _ready():
  Global.show_hint.connect(_on_show_hint)
  Global.hide_hint.connect(_on_hide_hint)
  messages.visible = false
  for c in messages.get_children():
    c.visible = false
  get_viewport().size_changed.connect(adjust_font_size)
  adjust_font_size()

func adjust_font_size()->void:
  theme.set_default_font_size(initial_font_size * Utils.get_viewport_scale(self))

func _on_show_hint(label:Label):
  if label == last_hint:
    return
  if last_hint:
    last_hint.visible = false
  last_hint = label
  last_hint.visible = true
  messages.visible = true

func _on_hide_hint(label:Label):
  if last_hint == label:
    last_hint.visible = false
    last_hint = null
    messages.visible = false

