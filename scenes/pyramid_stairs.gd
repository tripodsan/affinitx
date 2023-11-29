extends Node3D
class_name PyramidStairs

var _tower:Tower

var _tower_locked:bool = false

@onready var lasers = $lasers

func _ready():
  if Global.console:
    Global.console.command.connect(func(cmd): if cmd == 'tower': _grow())
  for l in lasers.get_children():
    l.activation_changed.connect(_on_laser_activation_changed)

func _on_tower_socket_body_entered(body):
  print_debug('tower enter')
  if body is Tower and !_tower:
    _tower = body
    _tower.pickable_component.picked_up.connect(_on_tower_picked_up)
    _tower.global_position = $tower_socket.global_position + Vector3(0, 1.0, 0)
    _tower.rotation = Vector3.ZERO
    _tower.freeze = true
    for l in lasers.get_children():
      l.tower_locked = true


func _on_tower_socket_body_exited(body):
  print_debug('tower exit')
  if body == _tower:
    _tower.pickable_component.picked_up.disconnect(_on_tower_picked_up)
    _tower.freeze = false
    _tower = null
    for l in lasers.get_children():
      l.tower_locked = false

func _on_tower_picked_up():
  print_debug('pickup')
  pass

func _grow():
  if not _tower:
    print_debug('no tower to grow')
    return

  if _tower_locked:
    return

  # TODO!!!!
  var scmp:ScaleComponent = ScaleComponent.from_parent(_tower)
  _tower.freeze = true
  _tower_locked = true
  scmp.scale_max = 25
  scmp.scale_time = 0
  scmp.scale_dir = Global.BEAM_MODE.GROW
  scmp.set_scaling(true)
  for l in lasers.get_children():
    l.lock_target()

func _on_laser_activation_changed():
  if not _tower: return
  if lasers.get_children().all(func(l): return l.activated):
    # TODO: player some music!
    Global._on_console_command('night')
    await get_tree().create_timer(2.0).timeout
    _grow()

