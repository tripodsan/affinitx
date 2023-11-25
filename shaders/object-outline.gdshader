shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;

uniform sampler2D viewport_texture;
uniform vec4 line_color: source_color = vec4(1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;

//void vertex() {
//  POSITION = vec4(VERTEX, 1.0);
//}

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
  ALPHA = outline - color.a;
//  ALBEDO = color.rgb;
//  ALPHA = 1.0;
}