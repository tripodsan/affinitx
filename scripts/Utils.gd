extends Object
class_name Utils

enum GUN_MODE {NONE, STOWED, IDLE, AIM}

enum CAMERA_MODE {FIRST, THIRD}

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

