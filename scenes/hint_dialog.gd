extends Control

@onready var messages = $margin/messages

func _ready():
  visible = false
  assert(!Global.connect('show_hint', _on_show_hint))

func _on_show_hint(label:Label):
  for c in messages.get_children():
    c.visible = c == label
  visible = !!label

