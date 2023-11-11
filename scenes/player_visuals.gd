extends Node3D

class_name PlayerVisuals

@onready var gun:Node3D = %gun
@onready var gun_idle:Node3D = $gun_skeleton/BoneAttachment3D/gun_idle
@onready var gun_aim_idle:Node3D = $gun_skeleton/BoneAttachment3D/gun_aim_idle
@onready var gun_aim_run:Node3D = $gun_skeleton/BoneAttachment3D/gun_aim_run
@onready var gun_aim_walk:Node3D = $gun_skeleton/BoneAttachment3D/gun_aim_walk
@onready var gun_first_person:Node3D = $gun_first_person
@onready var gun_skeleton:Node3D = $gun_skeleton
@onready var player_skeleton:Node3D = $Armature/Skeleton3D

@onready var ik0 = $Armature/Skeleton3D/GunTipIK
@onready var ik1 = $Armature/Skeleton3D/GunHandleIK

@onready var animation:AnimationPlayer = $AnimationPlayer

var gun_mode:Utils.GUN_MODE = -1

var animations = {
  Utils.GUN_MODE.NONE: {
    'walk': 'Walk',
    'run': 'Running',
    'idle': '0_Idle',
  },
  Utils.GUN_MODE.IDLE: {
    'walk': 'Walk Gun',
    'run': 'Running Gun',
    'idle': '0_Idle Gun',
  },
  Utils.GUN_MODE.AIM: {
    'walk': 'Walk Gun Aim',
    'run': 'Running Gun Aim',
    'idle': '0_Idle Gun Aim',
  }
}

func set_camera_mode(mode:Utils.CAMERA_MODE):
  if mode == Utils.CAMERA_MODE.FIRST:
    Utils.setCastShadowDeep(player_skeleton, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY)
    gun.visible = false
    gun_first_person.visible = true
  else:
    Utils.setCastShadowDeep(player_skeleton, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
    gun.visible = true
    gun_first_person.visible = false

func set_gun_mode(mode:Utils.GUN_MODE):
  gun_mode = mode
  if mode == Utils.GUN_MODE.NONE:
    ik0.stop()
    ik1.stop()
    gun_skeleton.visible = false
  else:
    gun_skeleton.visible = true
    set_gun_parent(gun_aim_idle)
    ik0.start()
    ik1.start()
  if mode != Utils.GUN_MODE.AIM:
    gun.rotation = Vector3.ZERO
    gun_first_person.rotation = Vector3.ZERO

func set_gun_parent(aim_parent:Node3D):
  if gun_mode == Utils.GUN_MODE.IDLE:
    gun.reparent(gun_idle, false)
  else:
    gun.reparent(aim_parent, false)

func run():
  var anim = animations[gun_mode];
  animation.play(anim.run, 0.1, 1.3)
  set_gun_parent(gun_aim_run)

func walk():
  var anim = animations[gun_mode];
  animation.play(anim.walk, 0.1, 1.3)
  set_gun_parent(gun_aim_walk)

func idle():
  var anim = animations[gun_mode];
  animation.play(anim.idle, 0.1)
  set_gun_parent(gun_aim_idle)

func fall():
  animation.play('Falling', 0.2)

func aim_at(pos:Vector3):
  if gun.visible:
    gun.look_at(pos)
  if gun_first_person.visible:
    gun_first_person.look_at(pos)
