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
      var scmp:ScaleComponent = ScaleComponent.from_parent(body)
      if scmp:
        scmp.parent_scale = scale_factor
      for child in body.get_children():
        if child is Node3D:
          child.scale = Vector3.ONE * scale_factor
          child.global_position = (child.global_position - origin) * scale_ratio + origin
          # assume no mode rigid bodies below
    elif body is Node3D:
      fix_rigid_body_scale(body, scale_factor, origin, scale_ratio)
