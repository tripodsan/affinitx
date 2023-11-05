extends CharacterBody3D


const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
var speed:float = 0.0

const JUMP_VELOCITY = 4.0
const SENSITIVITY = 0.001

# bob settings
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# fov settings
const FOV_BASE = 75.0
const FOV_FACTOR = 1.5

var gravity = 9.8

@onready var head = $head
@onready var camera:Camera3D = $head/camera

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  pass

func _unhandled_input(event):
  if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
    return

  if event is InputEventMouseMotion:
    rotate_y(-event.relative.x * SENSITIVITY)
    camera.rotate_x(-event.relative.y * SENSITIVITY)
    camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(70))


func _input(event):
  if event.is_action_pressed("ui_cancel"):
      Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  if event.is_action_pressed("click"):
    if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
      Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
      velocity.x = direction.x * speed
      velocity.z = direction.z * speed
    else:
      velocity.x = lerp(velocity.x, 0.0, delta * 10.0)
      velocity.z = lerp(velocity.z, 0.0, delta * 10.0)

  else:
    velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
    velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)


  # Handle head bob
  t_bob += delta * velocity.length() * float(is_on_floor())
  camera.transform.origin = _headbob(t_bob)

  # handle fov
#  var v_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
#  var target_fov = FOV_BASE + FOV_FACTOR * v_clamped
#  camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

  move_and_slide()


func _headbob(t:float)->Vector3:
  var pos = Vector3.ZERO
  pos.y = sin(t * BOB_FREQ) * BOB_AMP
  pos.x = cos(t * BOB_FREQ / 2.0) * BOB_AMP
  return pos
