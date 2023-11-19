@tool
extends Node3D

class_name PlayerVisuals

@onready var gun:Gun = %gun
@onready var gun_tip:Node3D = %gun/tip
@onready var gun_handle:Node3D = %gun/handle
@onready var gun_idle:Node3D = $gun_skeleton/BoneAttachment3D/gun_idle
@onready var gun_stowed:Node3D = $gun_skeleton/BoneAttachment3D/gun_stowed
@onready var gun_aim_idle:Node3D = $gun_skeleton/BoneAttachment3D/gun_aim_idle
@onready var gun_aim_run:Node3D = $gun_skeleton/BoneAttachment3D/gun_aim_run
@onready var gun_aim_walk:Node3D = $gun_skeleton/BoneAttachment3D/gun_aim_walk
@onready var gun_first_person:Gun = $gun_skeleton/gun_first_person
@onready var gun_skeleton:Node3D = $gun_skeleton
@onready var player_skeleton:Node3D = $Armature/Skeleton3D

@onready var ik0 = $Armature/Skeleton3D/GunTipIK
@onready var ik1 = $Armature/Skeleton3D/GunHandleIK

@onready var animation:AnimationPlayer = $AnimationPlayer

enum POSE { IDLE, WALK, RUN, FALL }

@export var pose:POSE = POSE.IDLE: set = set_pose

@export var gun_mode:Global.GUN_MODE = Global.GUN_MODE.NONE: set = set_gun_mode

@export var camera_mode:Global.CAMERA_MODE = Global.CAMERA_MODE.THIRD: set = set_camera_mode

var gun_aim:Vector3

@export var hide_player_mesh:bool = false:
  set(v):
    hide_player_mesh = v
    if v:
      Utils.setCastShadowDeep(player_skeleton, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY)
    else:
      Utils.setCastShadowDeep(player_skeleton, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)

@onready var animations = {
  Global.GUN_MODE.NONE: {
    POSE.IDLE: {
      'anim': '0_Idle',
      'parent': gun_idle,
      'speed': 1.0,
    },
    POSE.WALK: {
      'anim': 'Walk',
      'parent': gun_idle,
      'speed': 1.3,
    },
    POSE.RUN: {
      'anim': 'Running',
      'parent': gun_idle,
      'speed': 1.3,
    },
  },
  Global.GUN_MODE.STOWED: {
    POSE.IDLE: {
      'anim': '0_Idle',
      'parent': gun_stowed,
      'speed': 1.0,
    },
    POSE.WALK: {
      'anim': 'Walk',
      'parent': gun_stowed,
      'speed': 1.3,
    },
    POSE.RUN: {
      'anim': 'Running',
      'parent': gun_stowed,
      'speed': 1.3,
    },
  },
  Global.GUN_MODE.IDLE: {
    POSE.IDLE: {
      'anim': '0_Idle Gun',
      'parent': gun_idle,
      'speed': 1.0,
    },
    POSE.WALK: {
      'anim': 'Walk Gun',
      'parent': gun_idle,
      'speed': 1.3,
    },
    POSE.RUN: {
      'anim': 'Running Gun',
      'parent': gun_idle,
      'speed': 1.3,
    },
  },
  Global.GUN_MODE.AIM: {
    POSE.IDLE: {
      'anim': '0_Idle Gun Aim',
      'parent': gun_aim_idle,
      'speed': 1.0,
    },
    POSE.WALK: {
      'anim': 'Walk Gun Aim',
      'parent': gun_aim_walk,
      'speed': 1.3,
    },
    POSE.RUN: {
      'anim': 'Running Gun Aim',
      'parent': gun_aim_run,
      'speed': 1.3,
    },
  }
}

func set_camera_mode(mode:Global.CAMERA_MODE):
  camera_mode = mode
  if mode == Global.CAMERA_MODE.FIRST:
    hide_player_mesh = true
    gun.visible = false
    gun_first_person.visible = true
  else:
    hide_player_mesh = false
    gun.visible = true
    gun_first_person.visible = false
  set_gun_mode(gun_mode)

func set_gun_mode(mode:Global.GUN_MODE):
  gun_mode = mode
  if !ik0: return
  if mode != Global.GUN_MODE.AIM:
    gun_first_person.rotation = Vector3.ZERO
    gun.rotation = Vector3.ZERO
    ## TODO: investigate why this does not work!!
    if !Engine.is_editor_hint():
      gun_first_person.set_aim(false)
      gun.set_aim(false)
  if camera_mode == Global.CAMERA_MODE.FIRST:
    gun_first_person.visible = mode == Global.GUN_MODE.IDLE or mode == Global.GUN_MODE.AIM
    gun_skeleton.visible = mode != Global.GUN_MODE.NONE
    return

  if mode == Global.GUN_MODE.NONE:
    ik0.stop()
    ik1.stop()
    gun_skeleton.visible = false
  elif mode == Global.GUN_MODE.STOWED:
    ik0.stop()
    ik1.stop()
    gun_skeleton.visible = true
    update_gun_parent()
  else:
    gun_skeleton.visible = true
    update_gun_parent()
    ik0.start()
    ik1.start()
  set_pose(pose)

func set_pose(p:POSE):
  if p == POSE.FALL:
    animation.play('Falling', 0.2)
  else:
    pose = p
    var info = animations[gun_mode][pose]
    if info.anim != animation.current_animation:
      animation.play(info.anim, 0.1, info.speed)
      update_gun_parent()

func update_gun_parent():
  var parent = animations[gun_mode][pose].parent
  if parent and parent != gun.get_parent():
    gun.reparent(parent, false)
    gun.owner = self
    gun_tip.owner = self
    gun_handle.owner = self
    ik0.target_node = ik0.get_path_to(gun_tip)
    ik1.target_node = ik1.get_path_to(gun_handle)

func get_active_gun()->Gun:
  return gun if camera_mode == Global.CAMERA_MODE.THIRD else gun_first_person

func aim_at(pos:Vector3):
  gun_aim = pos
  var g:Gun = get_active_gun()
  g.look_at(pos)
  g.set_aim(true)
