extends Node

signal show_hint(label:Label)

enum GAME_EVENT { NONE, GOT_WEAPON }

## triggered when major game event happened
signal game_event(evt:GAME_EVENT)
