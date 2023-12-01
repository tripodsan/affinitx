extends Control

@onready var message_container = $margin/message_container
@onready var message = $margin/message_container/message

var last_message:String

func _ready():
  Global.show_hint.connect(_on_show_hint)
  Global.hide_hint.connect(_on_hide_hint)
  message_container.visible = false

func _on_show_hint(text:String):
  var msg = Settings.format_action_text(text)
  if msg != message.text:
    message.text = msg
  message_container.visible = true

func _on_hide_hint(text:String):
  var msg = Settings.format_action_text(text)
  if msg == message.text:
    message_container.visible = false

