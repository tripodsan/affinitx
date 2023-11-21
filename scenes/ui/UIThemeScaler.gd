extends Control

## Keeps trac of viewport resizing and adjusts the default font sizes of the specified themes
class_name UIThemeScaler

const META_NAME = 'initial_font_size'

@export var tracked_themes:Array[Theme] = []

func _ready():
  get_viewport().size_changed.connect(adjust_font_size)
  for theme in tracked_themes:
    theme.set_meta(META_NAME, theme.get_font_size('default', 'default'))
  adjust_font_size()

func adjust_font_size()->void:
  var ui_scale:float = Utils.get_viewport_scale(self)
  for theme in tracked_themes:
    theme.set_default_font_size(theme.get_meta(META_NAME) * ui_scale)

