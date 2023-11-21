@tool
extends Label

class_name GameTitle

@export var preview:bool = false

@export var autoplay:bool = false

@export var delay:float = 1.0

@export var play:bool = false: set = set_play

@export var display_time:float = 2.0

@export var transition_speed:float = 1.0

@export var trigger:Trigger

@export var enabled:bool = true

var time:float = 0

var fade_diretion:float = 1

func _ready():
  if Engine.is_editor_hint():
    visible = true
    modulate.a = 1.0
    lines_skipped = 0
    return
  visible = false
  if autoplay:
    start()
  elif trigger:
    trigger.activate.connect(start)

func start():
  if !enabled:
    return
  if delay:
    get_tree().create_timer(delay).timeout.connect(func (): play = true)
  else:
    play = true

func _process(delta):
  if !play: return

  if !preview and Engine.is_editor_hint(): return

  time = time + transition_speed * delta
  if fade_diretion > 0:
    modulate.a = smoothstep(0, 1, time)
    if time >= 1.0:
      fade_diretion = 0
      time = 0
  elif fade_diretion < 0:
    modulate.a = smoothstep(1, 0, time)
    if time >= 1.0:
      fade_diretion = 1
      time = 0
      lines_skipped += 1
      if lines_skipped >= get_line_count():
        play = false
        visible = false
        enabled = false

  else:
    if time >= display_time:
      fade_diretion = -1
      time = 0

func set_play(v:bool):
  if play == v:
    return
  play = v
  if v:
    reset()

func reset():
  visible = true
  modulate.a = 0
  lines_skipped = 0
  time = 0
  fade_diretion = 1


