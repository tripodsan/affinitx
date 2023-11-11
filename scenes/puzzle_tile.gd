extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
  assert(!$button_n.connect("input_event", func(): _test('n')));
  pass # Replace with function body.

func _test(n):
  print_debug(n);

func _on_input_event(camera, event, position, normal, shape_idx, direction):
  if event is InputEventMouseButton and event.pressed:
    print_debug(event, position, direction)
