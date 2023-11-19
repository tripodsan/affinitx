extends Node
class_name GameEventProxy

@export var game_event:Global.GAME_EVENT

func _on_external_event():
  Global.player_event(game_event)
