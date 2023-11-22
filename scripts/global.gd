extends Node

enum GAME_EVENT {
  NONE,
  GOT_WEAPON,
  DRAW_WEAPON,
  SHRINK_PILAR,
  CHECKPOINT_REACHED,
  LIFT_PUZZLE_SOLVED
}

enum BEAM_MODE { SHRINK, GROW }

enum GUN_MODE {NONE, STOWED, IDLE, AIM}

enum CAMERA_MODE {FIRST, THIRD}

var checkpoints:Array[Checkpoint] = []

var last_checkpoint:Checkpoint

var console:Console

signal show_hint(label:Label)

signal hide_hint(label:Label)

## triggered when major game event happened
signal game_event(evt:GAME_EVENT)

## triggered when the weapon changes
signal weapon_change(gun:Gun)

## triggered when checkpoint reached
signal checkpoint(cp:Checkpoint)

## triggered when target lock changed
signal target_lock_changed(enabled:bool)

var events = {}

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event)->void:
  if event.is_action_pressed("ui_cancel"):
    if is_console_open():
      console.close()
    else:
      Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  if event.is_action_pressed("console"):
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().root.set_input_as_handled()
    console.open()
  if event.is_action_pressed("click"):
    if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
      Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  if event.is_action_pressed("debug"):
    console.debug_toggle()

func player_event(evt:GAME_EVENT):
  if !events.has(evt):
    events[evt] = true
    game_event.emit(evt)
    console.log_info('game event achieved: "%s"' % GAME_EVENT.keys()[evt])

func player_killed(by:Node3D)->void:
  console.log_info('player killed by "%s"' % by.name)
  if last_checkpoint:
    last_checkpoint.teleport_player = true


## -------------- checkpoint

func register_checkpoint(cp:Checkpoint)->void:
  checkpoints.push_back(cp)

func checkpoint_reached(cp:Checkpoint):
  last_checkpoint = cp
  player_event(GAME_EVENT.CHECKPOINT_REACHED)
  checkpoint.emit(cp)
  console.log_info('checkpoint reached: "%s"' % cp.title)


## -------------- consoles

func is_console_open()->bool:
  return console and console.is_console_enabled

func set_console(c:Console)->void:
  console = c
  console.console_close.connect(_on_console_close)
  console.command.connect(_on_console_command)

func _on_console_close()->void:
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_console_command(cmd:String)->void:
  if cmd == 'quit':
    get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    get_tree().quit()

