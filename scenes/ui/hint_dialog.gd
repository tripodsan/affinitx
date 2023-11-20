extends Control

@onready var message_container = $margin/message_container
@onready var message = $margin/message_container/message

@onready var initial_font_size:int = theme.get_font_size('default', 'default')

var last_message:String

func _ready():
  Global.show_hint.connect(_on_show_hint)
  Global.hide_hint.connect(_on_hide_hint)
  message_container.visible = false
  get_viewport().size_changed.connect(adjust_font_size)
  adjust_font_size()

func adjust_font_size()->void:
  theme.set_default_font_size(initial_font_size * Utils.get_viewport_scale(self))

func _on_show_hint(text:String):
  if text != message.text:
    message.text = text
  message_container.visible = true

func _on_hide_hint(text:String):
  if text == message.text:
    message_container.visible = false

