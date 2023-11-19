@tool
extends Control

@onready var messages = $margin/messages

@export_range(0.0, 0.1, 0.001) var font_scale:float = 0.01:
  set(v):
    font_scale = v
    if Engine.is_editor_hint():
      adjust_font_size()

func _ready():
  adjust_font_size()
  get_viewport().size_changed.connect(adjust_font_size)
  _on_show_hint(null)
  if !Engine.is_editor_hint():
    Global.show_hint.connect(_on_show_hint)

func adjust_font_size()->void:
  theme.set_default_font_size(int(get_viewport_rect().size.y * font_scale * Utils.get_hdpi_scale()))

func _on_show_hint(label:Label):
  for c in messages.get_children():
    c.visible = c == label
  visible = !!label

