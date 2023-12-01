extends Control


func _enter_tree() -> void:
  Settings.opened.connect(_on_settings_opened)
  Settings.closed.connect(_on_settings_closed)

func _exit_tree() -> void:
  Settings.opened.disconnect(_on_settings_opened)
  Settings.closed.disconnect(_on_settings_closed)

func _on_settings_opened():
  visible = false

func _on_settings_closed():
  visible = true
