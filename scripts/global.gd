extends Node

enum GAME_EVENT {
  NONE,
  GOT_WEAPON,
  DRAW_WEAPON,
  SHRINK_PILAR,
  CHECKPOINT_REACHED,
  LIFT_PUZZLE_SOLVED,
  PLAYER_KILLED,
  MAZE_PUZZLE_SOLVED,
  TOWER_ACTIVATED,
  TOWER_ENTERED
}

var archievements = {
  GAME_EVENT.LIFT_PUZZLE_SOLVED: 'you solved the lift puzzle!',
  GAME_EVENT.MAZE_PUZZLE_SOLVED: 'you solved the micro-maze!'
}

enum BEAM_MODE { SHRINK, GROW }

enum GUN_MODE {NONE, STOWED, IDLE, AIM}

enum CAMERA_MODE {FIRST, THIRD}

var checkpoints:Array[Checkpoint] = []

var last_checkpoint:Checkpoint

var console:Console

var current_level:int = 0

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

## simple daytime
signal daytime_change()

var events = {}

var DEBUG:bool = false

var SKIP_TITLE:bool = false

var is_day:bool = true

func _input(event)->void:
  if current_level == 0:
    return
  if Settings.visible:
    return
  if event.is_action_pressed("ui_cancel"):
    if is_console_open():
      console.close()
    else:
      get_tree().paused = true
      Settings.closed.connect(_on_settings_closed)
      Settings.restart.connect(_on_settings_restart)
      Settings.open()
      Settings.process_mode = PROCESS_MODE_WHEN_PAUSED
      Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  if event.is_action_pressed("console"):
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().root.set_input_as_handled()
    console.open()
  if event is InputEventMouseButton and event.is_pressed():
    if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
      Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  if event.is_action_pressed("debug"):
    console.debug_toggle()

func _on_settings_closed():
  Settings.closed.disconnect(_on_settings_closed)
  Settings.restart.disconnect(_on_settings_restart)

  get_tree().paused = false
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_settings_restart():
  resurrect()
  Settings.close()

func player_event(evt:GAME_EVENT):
  if !events.has(evt):
    events[evt] = true
    game_event.emit(evt)
    console.log_info('game event achieved: "%s"' % GAME_EVENT.keys()[evt])
    var msg = archievements.get(evt)
    if msg:
      show_notification(msg)
    if evt == GAME_EVENT.TOWER_ENTERED:
      end_game()

func player_killed(by:Node3D)->void:
  var hcmp:HitBoxComponent = HitBoxComponent.from_parent(by)
  var msg:String = 'you %s' % hcmp.message if hcmp else str(by.name)
  console.log_info(msg)
  show_notification(msg)
  resurrect()

func resurrect():
  if last_checkpoint:
    last_checkpoint.teleport_player = true
  else:
    start_game()

func show_notification(msg:String, _duration:float = 2.0):
  show_hint.emit(msg)
  get_tree().create_timer(2.0).timeout.connect(func(): hide_hint.emit(msg))

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
    quit_game()
  elif cmd == 'give':
    var p = get_tree().get_first_node_in_group('Player')
    if p:
      p.set_gun_mode(Global.GUN_MODE.STOWED)
      console.close()
  elif cmd == 'day':
    if !is_day:
      is_day = true
      daytime_change.emit()
  elif cmd == 'night':
    if is_day:
      is_day = false
      daytime_change.emit()

## ---------------------- game controller

#var world_scene = preload('res://scenes/world/world.tscn').instantiate()

func quit_game():
    get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    get_tree().quit()

func start_game():
  current_level = 1
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  await SceneTransition.change_scene('res://scenes/world/world.tscn')
  BackgroundMusic.play()

func end_game():
  current_level = 0
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  SceneTransition.change_scene('res://scenes/thank_you.tscn', 0.5, true)

func show_title_screen():
  SceneTransition.change_scene('res://scenes/title.tscn')
