extends Object
class_name Utils

## Calculates the bounding box of the given node recursively
## [param parent] the node to iterate
static func getBoundingBoxDeep(node:Node3D)->AABB:
  var aabb:AABB = node.global_transform * node.get_aabb() if node is VisualInstance3D else AABB()
  for child in node.get_children():
    aabb = aabb.merge(getBoundingBoxDeep(child))
  return aabb
