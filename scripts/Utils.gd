extends Object
class_name Utils

## Calculates the bounding box of the given node recursively
## [param parent] the node to iterate
static func getBoundingBoxDeep(node:Node3D)->AABB:
  var aabb:AABB = node.global_transform * node.get_aabb() if node is VisualInstance3D else AABB()
  for child in node.get_children():
    aabb = aabb.merge(getBoundingBoxDeep(child))
  return aabb

static func setCastShadowDeep(node:Node3D, value:GeometryInstance3D.ShadowCastingSetting):
  if node is GeometryInstance3D:
    node.cast_shadow = value
  for child in node.get_children():
    if child is Node3D:
      setCastShadowDeep(child, value)

static func get_viewport_scale(node:CanvasItem)->float:
  var conf_height:int = ProjectSettings.get_setting('display/window/size/viewport_height')
  return float(node.get_viewport_rect().size.y) / float(conf_height)

static func set_layer_mask_value_deep(node:Node3D, layer_number: int, value: bool):
  if node is VisualInstance3D:
    node.set_layer_mask_value(layer_number, value)
  for child in node.get_children():
    if child is Node3D:
      set_layer_mask_value_deep(child, layer_number, value)

static func fix_rigid_body_scale(node:Node3D, scale_factor:float, origin:Vector3, scale_ratio:float):
  for body in node.get_children():
    if body is RigidBody3D:
#      body.apply_scale(origin, 1.0/scale_ratio)
      for child in body.get_children():
        if child is Node3D:
          child.scale = Vector3.ONE * scale_factor
          child.global_position = (child.global_position - origin) * scale_ratio + origin
          # assume no mode rigid bodies below
    elif body is Node3D:
      fix_rigid_body_scale(body, scale_factor, origin, scale_ratio)

#
#
#
#
#  func _scale_3d(body: RigidBody3D):
#	# First, we'll set this node to use "top level" mode. This basically
#	# disconnects it from its parents transform3d (which a rigidbody3d would
#	# do either way, because it's simulated in the physics world). It has the
#	# added advantage of transferring the body's current world scale into
#	# its own transform, so we can access it through body.scale (there is
#	# no easy way to quickly get a node3d's world scale from a parented transform.)
#	body.top_level = true
#
#	# If the node has a scale of 1, there's nothing for us to do.
#	if body.scale.x == 1: return
#
#	# Apply scale to all children before we reset it
#	for child in body.get_children():
#		if child is Node3D:
#			child.scale *= body.scale
#			child.transform.origin *= body.scale
#
#	# Reset the rigidbody's scale to 1
#	body.scale = Vector3.ONE
