shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, depth_test_disabled;

/*

Draws an object outline with bloom effect. It uses a viewport texture from a
camera that only renders the objects that need an outline, eg a select object.
The camera environment also applies a glow/bloom effect which oversaturates the object.
it calculates the outline and also removes all pixles that are too bright and applies
the outline again.

becasue we can't read the depth buffer of the viewport, we cannot map the pixels back into
the world. I think this would allow to render it close to the object. but instead we
have a 2nd viewport that renders the objects that should mask the outline, eg the 3rd person
player or some static objects (not the ground, though).

*/

uniform sampler2D viewport_texture;
uniform sampler2D viewport_mask_texture;

uniform vec4 line_color: source_color = vec4(1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
  // compute pixel size
  vec2 size = line_thickness / VIEWPORT_SIZE;

  float outline = 0.0;
  vec2 uv = SCREEN_UV;
  outline += texture(viewport_texture, uv + vec2(-size.x,       0)).a;
  outline += texture(viewport_texture, uv + vec2(      0,  size.y)).a;
  outline += texture(viewport_texture, uv + vec2( size.x,       0)).a;
  outline += texture(viewport_texture, uv + vec2(      0, -size.y)).a;
  outline += texture(viewport_texture, uv + vec2(-size.x,  size.y)).a;
  outline += texture(viewport_texture, uv + vec2( size.x,  size.y)).a;
  outline += texture(viewport_texture, uv + vec2(-size.x, -size.y)).a;
  outline += texture(viewport_texture, uv + vec2( size.x, -size.y)).a;
  outline = min(outline, 1.0);

  vec4 color = texture(viewport_texture, uv);

  ALBEDO = line_color.rgb;

  float a = clamp(color.r * 2.0, 0.0, 1.0);
  if (a == 1.0) {
    a = 0.0;
  }
//  a *= (cos(TIME * pulse) + 1.0) / 2.0;
  a += outline - color.a;
  if (texture(viewport_mask_texture, uv).a > 0.0) {
    a = 0.0;
  };
  ALPHA = a;
}

