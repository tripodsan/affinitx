extends Control

@export var regenerate:bool: set = _recalc

@onready var action_grid: GridContainer = %action_grid
@onready var inputs: HBoxContainer = %inputs
@onready var back_btn: Button = %back_btn
@onready var restart_btn: Button = $inputs/menu/restart

class Selection:
  var action:String
  var label:Label
  var button:Button
  func _init(a:String, l:Label, b:Button):
    action = a
    label = l
    button = b

var _selection:Selection = null

signal opened()

signal closed()

signal restart()

static var config_path:String = 'user://settings.cfg'

static var config:ConfigFile = ConfigFile.new()

const ignored_actions:Array[String] = ['debug', 'console']

var actions_map:Dictionary = {}

func save_settings():
  for action in InputMap.get_actions():
    if !action.begins_with('ui_'):
      var events:Array[InputEvent] = InputMap.action_get_events(action)
      if events[0] is InputEventKey:
        config.set_value('input', action, events[0])
        actions_map[action] = events[0].as_text_physical_keycode()
  var error = config.save(config_path)
  if error:
    print('error saving settings: ', error)
  else:
    print('settings saved to ', ProjectSettings.globalize_path(config_path))

func load_settings():
  var error = config.load(config_path)
  if error:
    print('unable to load config: ', error)
    return

  for action in config.get_section_keys('input'):
    var event:InputEventKey = config.get_value('input', action)
    if event:
      InputMap.action_erase_events(action)
      InputMap.action_add_event(action, event)
      actions_map[action] = event.as_text_physical_keycode()

func reset():
  InputMap.load_from_project_settings()
  save_settings()

var _in_ready = false

func _ready() -> void:
  load_settings()
  _in_ready = true
  _recalc()
  close()

func open():
  visible = true
  process_mode = Node.PROCESS_MODE_INHERIT
  back_btn.grab_focus()
  if Global.current_level:
    back_btn.text = 'Resume'
  else:
    back_btn.text = 'Back'
  restart_btn.visible = Global.current_level > 0

  opened.emit()

func close():
  visible = false
  process_mode = Node.PROCESS_MODE_DISABLED
  closed.emit()

func _input(event:InputEvent):
  if not event is InputEventKey: return
  if _selection:
    InputMap.action_erase_events(_selection.action)
    InputMap.action_add_event(_selection.action, event)
    save_settings()
    _selection.button.text = event.as_text_physical_keycode()
    _selection = null
    inputs.process_mode = Node.PROCESS_MODE_INHERIT
    get_viewport().set_input_as_handled()
  elif event.pressed and event.keycode == KEY_ESCAPE:
    close()

func _recalc(_ignore = false):
  if !_in_ready:return
  var t_action:Label
  var t_keyboard:Button
  for c in action_grid.get_children():
    if c.name == 'template_action':
      t_action = c
      c.visible = false
    elif c.name == 'template_keyboard':
      t_keyboard = c
      c.visible = false
    elif not c.name.begins_with('header_'):
      c.queue_free()
  for action in InputMap.get_actions():
    if !action.begins_with('ui_') and !ignored_actions.has(action):
      var events:Array[InputEvent] = InputMap.action_get_events(action)
      if events[0] is InputEventKey:
        var evt:InputEventKey = events[0]
        var a:Label = t_action.duplicate()
        a.text = tr(action)
        a.visible = true
        action_grid.add_child(a)
        a.owner = action_grid.owner
        var k:Button = t_keyboard.duplicate()
        k.text = evt.as_text_physical_keycode()
        k.visible = true
        action_grid.add_child(k)
        k.owner = action_grid.owner
        k.pressed.connect(_on_keyboard_btn.bind(action, a, k))

func _on_keyboard_btn(action:String, label:Label, btn:Button)->void:
  btn.text = '[press key]'
  _selection = Selection.new(action, label, btn)
  inputs.process_mode = Node.PROCESS_MODE_DISABLED

## formats the given string with the respective actions
func format_action_text(msg:String)->String:
  return msg.format(actions_map)

func _on_restart_pressed() -> void:
  restart.emit()

func _on_reset_pressed() -> void:
  reset()
  _recalc()
