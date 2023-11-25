extends CharacterBody3D
class_name Player

const WALK_SPEED = 2.9
const SPRINT_SPEED = 6.0
var speed:float = 0.0

const JUMP_VELOCITY = 4.0
const SENSITIVITY = 0.001

# bob settings
const BOB_FREQ = 4.0
const BOB_AMP = 0.08
var t_bob = 0.0

# fov settings
const FOV_BASE = 75.0
const FOV_FACTOR = 1.5

var gravity = 9.8

var last_direction:Vector3

@export var camera_mode:Global.CAMERA_MODE = Global.CAMERA_MODE.THIRD

@export var gun_mode:Global.GUN_MODE = Global.GUN_MODE.NONE

@onready var head_first = $camera_mount_first
@onready var head_third = $camera_mount_third
@onready var camera:Camera3D = %camera

@onready var visuals_container:Area3D = $visuals_container
@onready var visuals:PlayerVisuals = $visuals_container/visuals

var interaction_object

func _ready():
  visuals_container.area_entered.connect(_on_body_or_area_entered)
  visuals_container.area_exited.connect(_on_body_or_area_exited)
  visuals_container.body_entered.connect(_on_body_or_area_entered)
  visuals_container.body_exited.connect(_on_body_or_area_exited)
  get_tree().process_frame.connect(_reset, CONNECT_ONE_SHOT)

func _reset():
  set_camera_mode(camera_mode)
  set_gun_mode(gun_mode, true)

func _on_body_or_area_entered(node:Node3D):
  print('body entered:', node)
  # only check remember pickables
  var pickable:PickableComponent = PickableComponent.from_parent(node)
  if pickable:
    pickable.enable_highlight(true)
    interaction_object = node
    print('pickable')

func _on_body_or_area_exited(node:Node3D):
  print('body exited:', node)
  if node == interaction_object:
    var pickable:PickableComponent = PickableComponent.from_parent(node)
    if pickable:
      pickable.enable_highlight(false)
    interaction_object = null

func _unhandled_input(event):
  if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
    return

  if event is InputEventMouse:
    if gun_mode == Global.GUN_MODE.IDLE and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
      set_gun_mode(Global.GUN_MODE.AIM)
    elif gun_mode == Global.GUN_MODE.AIM and !event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
      set_gun_mode(Global.GUN_MODE.IDLE)
    elif gun_mode == Global.GUN_MODE.AIM and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
      fire_gun(true)
    elif gun_mode == Global.GUN_MODE.AIM and !event.button_mask & MOUSE_BUTTON_MASK_LEFT:
      fire_gun(false)

  if event is InputEventMouseMotion:
    rotate_y(-event.relative.x * SENSITIVITY)
    if gun_mode != Global.GUN_MODE.AIM && camera_mode != Global.CAMERA_MODE.FIRST:
      visuals_container.rotate_y(event.relative.x * SENSITIVITY)
    camera.rotate_x(-event.relative.y * SENSITIVITY)
    camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(70))

  if event.is_action_pressed("toggle_camera"):
    set_camera_mode(Global.CAMERA_MODE.FIRST if camera_mode == Global.CAMERA_MODE.THIRD else Global.CAMERA_MODE.THIRD)
  if event.is_action_pressed('toggle_lock'):
    var gun = visuals.get_active_gun()
    if gun:
      gun.toggle_target_lock()
  if event.is_action_pressed("toggle_weapon"):
    if gun_mode != Global.GUN_MODE.NONE:
      Global.player_event(Global.GAME_EVENT.DRAW_WEAPON)
      set_gun_mode(Global.GUN_MODE.STOWED if gun_mode != Global.GUN_MODE.STOWED else Global.GUN_MODE.IDLE)
  if event.is_action_pressed("interact"):
    _on_interact()

## checks if the player is controllable.
func is_controllable()->bool:
  return !Global.is_console_open()

func _physics_process(delta):
  # Add the gravity.
  if not is_on_floor():
    velocity.y -= gravity * delta

  # Handle sprint
  speed = (SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED)

  var direction = Vector3.ZERO

  if is_controllable():
    # Handle Jump.
    if Input.is_action_just_pressed("jump") and is_on_floor():
      velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    var input_dir = Input.get_vector("left", "right", "up", "down")
    direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

  if is_on_floor():
    if direction:
      if speed == WALK_SPEED:
        visuals.set_pose(PlayerVisuals.POSE.WALK)
      else:
        visuals.set_pose(PlayerVisuals.POSE.RUN)
      velocity.x = direction.x * speed
      velocity.z = direction.z * speed


      if gun_mode != Global.GUN_MODE.AIM && camera_mode != Global.CAMERA_MODE.FIRST:
        orient_towards(direction)

    else:
      visuals.set_pose(PlayerVisuals.POSE.IDLE)
      velocity.x = lerp(velocity.x, 0.0, delta * 10.0)
      velocity.z = lerp(velocity.z, 0.0, delta * 10.0)

  else:
    visuals.set_pose(PlayerVisuals.POSE.FALL)
    velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
    velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)

  last_direction = direction

  # Handle head bob
  if camera_mode == Global.CAMERA_MODE.FIRST:
    t_bob += delta * velocity.length() * float(is_on_floor())
    camera.transform.origin.y = sin(t_bob * BOB_FREQ) * BOB_AMP
    camera.transform.origin.x = cos(t_bob * BOB_FREQ / 2.0) * BOB_AMP

  # handle aiming
  if gun_mode == Global.GUN_MODE.AIM:
    var gun = visuals.get_active_gun()
    assert(gun)
    if gun.target_locked:
      visuals_container.look_at(gun.laser.hit_position)
    elif abs(visuals_container.rotation.y) > 0.1:
      visuals_container.rotation.y = lerp_angle(visuals_container.rotation.y, 0.0, delta * 15.0)
    else:
      visuals_container.rotation.y = 0
      visuals.aim_at(position + camera.global_transform.basis.z * 10.0)

  if move_and_slide():
    var lc = get_last_slide_collision()
    var col = lc.get_collider()
    if col is Node3D && HitBoxComponent.from_parent(col):
      Global.player_killed(col)
      return

#    for col_idx in get_slide_collision_count():
#      col = get_slide_collision(col_idx)
#      if col.get_collider() is RigidBody3D:
#        col.get_collider().apply_central_impulse(-col.get_normal() * 0.3)
#        col.get_collider().apply_impulse(-col.get_normal() * 0.01, col.get_position())


func set_camera_mode(mode:Global.CAMERA_MODE):
  if mode == Global.CAMERA_MODE.FIRST:
    camera.reparent(head_first, false)
    # when switching to firs-person, rotate the visuals forwards
    if camera_mode != mode:
      visuals_container.rotation.y = 0.0
  else:
    camera.reparent(head_third, false)
  camera_mode = mode
  visuals.set_camera_mode(mode)
  Global.console.log_info('set camera mode to %s' % Global.BEAM_MODE.keys()[mode])

func set_gun_mode(mode:Global.GUN_MODE, force:bool = false):
  if force or gun_mode != mode:
    gun_mode = mode
    visuals.set_gun_mode(mode)
    if mode != Global.GUN_MODE.STOWED and mode != Global.GUN_MODE.NONE:
      Global.weapon_change.emit(visuals.get_active_gun())
    else:
      Global.weapon_change.emit(null)
    Global.console.log_info('set gun mode to %s' % Global.GUN_MODE.keys()[mode])

func orient_towards(dir:Vector3, sp:float = 0.2):
  var tx_lookat = visuals_container.global_transform.looking_at(global_position + dir)
  visuals_container.global_transform = visuals_container.global_transform.interpolate_with(tx_lookat, sp)

func fire_gun(v:bool):
  var gun = visuals.get_active_gun()
  if gun:
    gun.fire(v)

func _on_interact():
  if !interaction_object:
    return
  if interaction_object is ItemStorage:
    _on_pick_item(interaction_object)
    return
  var pickable = PickableComponent.from_parent(interaction_object)
  if pickable and pickable.can_pickup():
    print('can pick')

func _on_pick_item(storage:ItemStorage):
  if storage.get_item() is Gun:
    storage.pick_item(true)
    set_gun_mode(Global.GUN_MODE.STOWED)
    Global.player_event(Global.GAME_EVENT.GOT_WEAPON)
