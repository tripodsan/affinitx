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
