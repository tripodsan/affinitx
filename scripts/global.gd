extends Node

signal show_hint(label:Label)

enum GAME_EVENT { NONE, GOT_WEAPON, DRAW_WEAPON, SHRINK_PILAR }

## triggered when major game event happened
signal game_event(evt:GAME_EVENT)

var events = {}

func player_event(evt:GAME_EVENT):
  if !events.has(evt):
    events[evt] = true
    game_event.emit(evt)
