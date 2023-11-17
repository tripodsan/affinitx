#@tool
extends Object

class_name PolyPrismMesh

@export_range(0.0, 5.0, 0.1, 'or greater') var radius:float = 1.0: set = set_radius

## TODO

func set_radius(r:float):
  if r > 0:
    radius = r
#    update()


#func update():
#  var vertices = PackedVector3Array()
#  vertices.push_back(Vector3(0, 1, 0))
#  vertices.push_back(Vector3(1, 0, 0))
#  vertices.push_back(Vector3(0, 0, 1))
#
#  # Initialize the ArrayMesh.
#  var arrays = []
#  arrays.resize(Mesh.ARRAY_MAX)
#  arrays[Mesh.ARRAY_VERTEX] = vertices
#
#  # Create the Mesh.
#  clear_surfaces()
#  add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
