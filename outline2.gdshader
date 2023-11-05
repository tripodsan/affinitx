shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_disabled;//, depth_prepass_alpha;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform float edge_normal_threshold: hint_range(0, 1) = 0.2;
uniform float edge_depth_threshold: hint_range(0, 10) = 5.0;
uniform float edge_normal_offset: hint_range(0, 1) = 1.0;
uniform float edge_depth_offset: hint_range(0, 1) = 1.0;
uniform vec3 line_color: source_color = vec3(0.043, 0.282, 0.467);
uniform vec3 background_color: source_color = vec3(0.408, 0.969, 0.694);

const mat3 sobel_y = mat3(
  vec3(1.0, 0.0, -1.0),
  vec3(2.0, 0.0, -2.0),
  vec3(1.0, 0.0, -1.0)
);

const mat3 sobel_x = mat3(
  vec3(1.0, 2.0, 1.0),
  vec3(0.0, 0.0, 0.0),
  vec3(-1.0, -2.0, -1.0)
);

varying mat4 CAMERA;

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
  CAMERA = INV_VIEW_MATRIX;
}

float calc_normal_edge(vec2 uv, vec2 offset) {
  vec3 normal = texture(NORMAL_TEXTURE, uv).rgb;
  normal = normal * 2.0 - 1.0;

  vec3 n = texture(NORMAL_TEXTURE, uv + vec2(0.0, -offset.y)).rgb;
  vec3 s = texture(NORMAL_TEXTURE, uv + vec2(0.0, offset.y)).rgb;
  vec3 e = texture(NORMAL_TEXTURE, uv + vec2(offset.x, 0.0)).rgb;
  vec3 w = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, 0.0)).rgb;
  vec3 nw = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, -offset.y)).rgb;
  vec3 ne = texture(NORMAL_TEXTURE, uv + vec2(offset.x, -offset.y)).rgb;
  vec3 sw = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, offset.y)).rgb;
  vec3 se = texture(NORMAL_TEXTURE, uv + vec2(offset.x, offset.y)).rgb;

  mat3 surrounding_pixels = mat3(
    vec3(length(nw-normal), length(n-normal), length(ne-normal)),
    vec3(length(w-normal), length(normal-normal), length(e-normal)),
    vec3(length(sw-normal), length(s-normal), length(se-normal))
  );

  float edge_x = dot(sobel_x[0], surrounding_pixels[0]) + dot(sobel_x[1], surrounding_pixels[1]) + dot(sobel_x[2], surrounding_pixels[2]);
  float edge_y = dot(sobel_y[0], surrounding_pixels[0]) + dot(sobel_y[1], surrounding_pixels[1]) + dot(sobel_y[2], surrounding_pixels[2]);

  float edge = sqrt(pow(edge_x, 2.0)+pow(edge_y, 2.0));
  return edge;
}

float getDepth(vec2 uv, mat4 inv_projection_matrix){
  float depth = texture(DEPTH_TEXTURE, uv).x;
  vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
  vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
  view.xyz /= view.w;
  float linear_depth = -view.z;
  return depth * 100.0;
  return linear_depth / 100.0;
}

float calc_depth_edge(vec2 uv, vec2 offset, mat4 inv_projection_matrix) {
  float n =  getDepth(uv + vec2(      0.0, -offset.y), inv_projection_matrix);
  float s =  getDepth(uv + vec2(      0.0,  offset.y), inv_projection_matrix);
  float e =  getDepth(uv + vec2( offset.x,       0.0), inv_projection_matrix);
  float w =  getDepth(uv + vec2(-offset.x,       0.0), inv_projection_matrix);
  float nw = getDepth(uv + vec2(-offset.x, -offset.y), inv_projection_matrix);
  float ne = getDepth(uv + vec2( offset.x, -offset.y), inv_projection_matrix);
  float sw = getDepth(uv + vec2(-offset.x,  offset.y), inv_projection_matrix);
  float se = getDepth(uv + vec2( offset.x,  offset.y), inv_projection_matrix);

  mat3 surrounding_pixels = mat3(
    vec3(nw, n, ne),
    vec3(w , 0, e),
    vec3(sw, s, se)
  );

  float edge_x = dot(sobel_x[0], surrounding_pixels[0]) + dot(sobel_x[1], surrounding_pixels[1]) + dot(sobel_x[2], surrounding_pixels[2]);
  float edge_y = dot(sobel_y[0], surrounding_pixels[0]) + dot(sobel_y[1], surrounding_pixels[1]) + dot(sobel_y[2], surrounding_pixels[2]);

  float edge = sqrt(pow(edge_x, 2.0)+pow(edge_y, 2.0));
  return edge;
}

float getMagicDepth(vec2 uv, mat4 inv_projection_matrix, vec3 view) {
  vec3 n = normalize(texture(NORMAL_TEXTURE, uv).xyz * 2.0 - 1.0);
  float depth = texture(DEPTH_TEXTURE, uv).x;
  vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
  vec4 world = inv_projection_matrix * vec4(ndc, 1.0);
  world.xyz /= world.w;
  float linear_depth = -world.z;

  return dot(n, view) * linear_depth / 10.0;
}

float calc_magic_edge(vec2 uv, vec2 offset, mat4 inv_projection_matrix, vec3 view) {
  float n =  getMagicDepth(uv + vec2(      0.0, -offset.y), inv_projection_matrix, view);
  float s =  getMagicDepth(uv + vec2(      0.0,  offset.y), inv_projection_matrix, view);
  float e =  getMagicDepth(uv + vec2( offset.x,       0.0), inv_projection_matrix, view);
  float w =  getMagicDepth(uv + vec2(-offset.x,       0.0), inv_projection_matrix, view);
  float nw = getMagicDepth(uv + vec2(-offset.x, -offset.y), inv_projection_matrix, view);
  float ne = getMagicDepth(uv + vec2( offset.x, -offset.y), inv_projection_matrix, view);
  float sw = getMagicDepth(uv + vec2(-offset.x,  offset.y), inv_projection_matrix, view);
  float se = getMagicDepth(uv + vec2( offset.x,  offset.y), inv_projection_matrix, view);

  mat3 surrounding_pixels = mat3(
    vec3(nw, n, ne),
    vec3(w , 0, e),
    vec3(sw, s, se)
  );

  float edge_x = dot(sobel_x[0], surrounding_pixels[0]) + dot(sobel_x[1], surrounding_pixels[1]) + dot(sobel_x[2], surrounding_pixels[2]);
  float edge_y = dot(sobel_y[0], surrounding_pixels[0]) + dot(sobel_y[1], surrounding_pixels[1]) + dot(sobel_y[2], surrounding_pixels[2]);

  float edge = sqrt(pow(edge_x, 2.0)+pow(edge_y, 2.0));
  return edge;
}

void fragment() {
  vec2 uv = SCREEN_UV;
  vec4 screen_color = texture(SCREEN_TEXTURE, uv);
  vec2 offset_normal = edge_normal_offset / VIEWPORT_SIZE;
  vec2 offset_depth = edge_depth_offset / VIEWPORT_SIZE;

  float edge = calc_normal_edge(uv, offset_normal);
  if (edge > edge_normal_threshold) {
    ALBEDO = line_color;
  } else {
    edge = calc_depth_edge(uv, offset_depth, INV_PROJECTION_MATRIX);
    if (edge > edge_depth_threshold) {
      ALBEDO = line_color;
    } else {
      ALBEDO = screen_color.rgb;
    }
  }

  vec3 n = normalize(texture(NORMAL_TEXTURE, uv).xyz * 2.0 - 1.0);
//  float depth = texture(DEPTH_TEXTURE, uv).x;
//  vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
//  vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
//  view.xyz /= view.w;
//  float linear_depth = -view.z;
//
//  vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
//  vec3 world_position = world.xyz / world.w;
//
//  vec3 ray = normalize(CAMERA_POSITION_WORLD - world_position);
//
//  float d0 = dot(n, VIEW) * linear_depth / 100.0;
////
//  float d0 = n.x;
//  ALBEDO = screen_color.rgb;
}