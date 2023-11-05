@tool
extends EditorPlugin

const TOOL_NAME = "Make StaticBody3d"

func _enter_tree():
  print_debug('tripod tools initialized');
  add_tool_menu_item(TOOL_NAME, callback)

func _exit_tree():
  remove_tool_menu_item(TOOL_NAME)

func callback():
  var sel:Array[Node] = get_editor_interface().get_selection().get_selected_nodes();
  for selected_node in sel:
    if selected_node is MeshInstance3D:
      var mesh:MeshInstance3D = selected_node
      var body:StaticBody3D = StaticBody3D.new()
      body.name = mesh.name + '_body'
      var owner = mesh.owner;

      print('replacing ', mesh, ' with static body ', body)
      mesh.add_sibling(body)
      body.global_position = mesh.global_position
      body.set_owner(owner)
      mesh.get_parent().remove_child(mesh)
      body.add_child(mesh)
      mesh.set_owner(owner)
      mesh.position = Vector3.ZERO

func _edit(object):
  print_debug(object)
