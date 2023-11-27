shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, depth_test_disabled;

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

