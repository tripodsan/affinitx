extends MeshInstance3D

# can't preload foward shader because it will cause an error on mobile exports
# var shader:Shader = preload("res://outline-forward.gdshader")

var shader_mobile:Shader = preload("res://outline-mobile.gdshader")

func _ready():
  var method = ProjectSettings.get_setting('rendering/renderer/rendering_method')
  var shader:Shader = shader_mobile
  if method == 'forward_plus':
    shader = load("res://outline-forward.gdshader")
    print('using normal map based outline shader for ', method)
  else:
    print('using depth based outline shader for ', method)

  get_active_material(0).set_shader(shader_mobile);

