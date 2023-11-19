extends PanelContainer
class_name Console

@onready var console_output:Label = %console_output

@onready var console_input:LineEdit = %console_input

var HELP_TEXT = '' \
  + '/tp    Teleport\n' \
  + '/give  Give Player Item\n' \
  + '/quit  Quit Game\n'

signal console_open()

signal console_close()

signal command(cmd:String)

var is_debug_enabled:bool = false

var is_console_enabled:bool = false

func _enter_tree():
  Global.set_console(self)

func _ready():
  visible = false
  console_input.text_submitted.connect(_on_text_submitted)
  console_input.text = ''
  console_input.modulate.a = 0
  console_output.text = ''
  log_info('Console 1.0')

func debug_toggle()->void:
  if is_debug_enabled:
    debug_close()
  else:
    debug_open()

func debug_open()->void:
  is_debug_enabled = true
  visible = true
  console_input.modulate.a = 0

func debug_close()->void:
  is_debug_enabled = false
  visible = false

func open()->void:
  visible = true
  is_console_enabled = true
  console_input.modulate.a = 1
  if !console_input.text:
    console_input.clear()
    console_input.text = '/'
    console_input.caret_column = 1
  console_input.grab_focus()
  console_open.emit()

func close()->void:
  is_console_enabled = false
  console_input.release_focus()
  console_close.emit()
  console_input.modulate.a = 0
  if !is_debug_enabled:
    visible = false

func _on_text_submitted(text:String)->void:
  console_input.text = ''
  var segs = text.split(' ', false)
  if segs.is_empty():
    return

  var cmd = segs[0]
  segs.remove_at(0)
  if cmd == '/quit':
    command.emit('quit')
  elif cmd == '/help':
    log_info(HELP_TEXT)
  elif cmd == '/tp':
    _handle_tp(segs)
  else:
    log_info('no such command.')

func log_info(msg:String)->void:
  prints('info:', msg)
  console_output.text += '\n%s' % msg

func _handle_tp(args:Array[String])->void:
  if args.is_empty():
    var msg = 'checkpoints:\n'
    for c in Global.checkpoints:
      msg += ' %s\n' % c.title
    log_info(msg)
  else:
    for c in Global.checkpoints:
      if c.title.to_lower() == args[0]:
        c.teleport_player = true
        close()
        return
    log_info('no such checkpoint.')


