extends Node

signal show_hint(label:Label)

enum GAME_EVENT { NONE, GOT_WEAPON, DRAW_WEAPON, SHRINK_PILAR, CHECKPOINT_REACHED }

var last_checkpoint:Checkpoint

## triggered when major game event happened
signal game_event(evt:GAME_EVENT)

## triggered when the weapon changes
signal weapon_change(gun:Gun)

## triggered when checkpoint reached
signal checkpoint(cp:Checkpoint)

var events = {}

func player_event(evt:GAME_EVENT):
  if !events.has(evt):
    events[evt] = true
    game_event.emit(evt)

func checkpoint_reached(cp:Checkpoint):
  last_checkpoint = cp
  player_event(GAME_EVENT.CHECKPOINT_REACHED)
  checkpoint.emit(cp)

