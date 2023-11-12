extends CharacterBody3D

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

var camera_mode:Utils.CAMERA_MODE = Utils.CAMERA_MODE.THIRD

var gun_mode:Utils.GUN_MODE = Utils.GUN_MODE.IDLE

@onready var head_first = $camera_mount_first
@onready var head_third = $camera_mount_third
@onready var camera:Camera3D = %camera

@onready var visuals_container:Node3D = $visuals_container
@onready var visuals:PlayerVisuals = $visuals_container/visuals

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  set_camera_mode(camera_mode)
  set_gun_mode(gun_mode, true)

func _unhandled_input(event):
  if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
    return

  if event is InputEventMouse:
    if gun_mode == Utils.GUN_MODE.IDLE and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
      set_gun_mode(Utils.GUN_MODE.AIM)
    elif gun_mode == Utils.GUN_MODE.AIM and !event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
      set_gun_mode(Utils.GUN_MODE.IDLE)
    elif gun_mode == Utils.GUN_MODE.AIM and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
      fire_gun(true)
    elif gun_mode == Utils.GUN_MODE.AIM and !event.button_mask & MOUSE_BUTTON_MASK_LEFT:
      fire_gun(false)

  if event is InputEventMouseMotion:
    rotate_y(-event.relative.x * SENSITIVITY)
    if gun_mode != Utils.GUN_MODE.AIM && camera_mode != Utils.CAMERA_MODE.FIRST:
      visuals_container.rotate_y(event.relative.x * SENSITIVITY)
    camera.rotate_x(-event.relative.y * SENSITIVITY)
    camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(70))


func _input(event):
  if event.is_action_pressed("ui_cancel"):
      Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  if event.is_action_pressed("click"):
    if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
      Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  if event.is_action_pressed("toggle_camera"):
    set_camera_mode(Utils.CAMERA_MODE.FIRST if camera_mode == Utils.CAMERA_MODE.THIRD else Utils.CAMERA_MODE.THIRD)
  if event.is_action_pressed("toggle_weapon"):
    set_gun_mode(Utils.GUN_MODE.IDLE if gun_mode != Utils.GUN_MODE.IDLE else Utils.GUN_MODE.NONE)

func _physics_process(delta):
  # Add the gravity.
  if not is_on_floor():
    velocity.y -= gravity * delta

  # Handle Jump.
  if Input.is_action_just_pressed("jump") and is_on_floor():
    velocity.y = JUMP_VELOCITY

  # Handle sprint
  speed = (SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED)

  # Get the input direction and handle the movement/deceleration.
  var input_dir = Input.get_vector("left", "right", "up", "down")
  var direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
  if is_on_floor():
    if direction:
      if speed == WALK_SPEED:
        visuals.walk()
      else:
        visuals.run()
      velocity.x = direction.x * speed
      velocity.z = direction.z * speed


      if gun_mode != Utils.GUN_MODE.AIM && camera_mode != Utils.CAMERA_MODE.FIRST:
        orient_towards(direction)

    else:
      visuals.idle()
      velocity.x = lerp(velocity.x, 0.0, delta * 10.0)
      velocity.z = lerp(velocity.z, 0.0, delta * 10.0)

  else:
    visuals.fall()
    velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
    velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)

  last_direction = direction

  # Handle head bob
  if camera_mode == Utils.CAMERA_MODE.FIRST:
    t_bob += delta * velocity.length() * float(is_on_floor())
    camera.transform.origin.y = sin(t_bob * BOB_FREQ) * BOB_AMP
    camera.transform.origin.x = cos(t_bob * BOB_FREQ / 2.0) * BOB_AMP

  # handle aiming
  if gun_mode == Utils.GUN_MODE.AIM:
    if abs(visuals_container.rotation.y) > 0.1:
      visuals_container.rotation.y = lerp_angle(visuals_container.rotation.y, 0.0, delta * 15.0)
    else:
      visuals_container.rotation.y = 0
      visuals.aim_at(position + camera.global_transform.basis.z * 10.0)

  move_and_slide()

func set_camera_mode(mode:Utils.CAMERA_MODE):
  if mode == Utils.CAMERA_MODE.FIRST:
    camera.reparent(head_first, false)
    # when switching to firs-person, rotate the visuals forwards
    if camera_mode != mode:
      visuals_container.rotation.y = 0.0
  else:
    camera.reparent(head_third, false)
  camera_mode = mode
  visuals.set_camera_mode(mode)

func set_gun_mode(mode:Utils.GUN_MODE, force:bool = false):
  if force or gun_mode != mode:
    gun_mode = mode
    visuals.set_gun_mode(mode)

func orient_towards(dir:Vector3, speed:float = 0.2):
  var tx_lookat = visuals_container.global_transform.looking_at(global_position + dir)
  visuals_container.global_transform = visuals_container.global_transform.interpolate_with(tx_lookat, speed)

func fire_gun(v:bool):
  var gun = visuals.get_active_gun()
  if gun:
    gun.fire(v)
