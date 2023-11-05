// Ported from https://roystan.net/articles/outline-shader/ by ERInteractive
shader_type spatial;
render_mode unshaded;

uniform float depth_threshold : hint_range(0.0,10.0,0.01) = 0.2f;
uniform float depth_normal_threshold_scale : hint_range(0.0,10.0,0.01) = 0.2f;
uniform float normal_threshold : hint_range(0.0,10.0,0.01) = 0.2f;
uniform vec4 edge_color: source_color;


uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXUTRE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXUTRE : hint_depth_texture, filter_linear_mipmap;

uniform float scale = 1.0;
void vertex()
{
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	float half_scale_floor = floor(scale * 0.5);
	float half_scale_ceil = ceil(scale * 0.5);

	vec2 SCREEN_PIXEL_SIZE = 1.0 / VIEWPORT_SIZE;

	// Flip UV on Y axis
	vec2 uv = UV * vec2(1.0,-1.0);

	vec2 bottom_left_UV = uv + vec2(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y) * half_scale_floor;
	vec2 top_right_UV =  uv + vec2(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y) * half_scale_ceil;
	vec2 bottom_right_UV =  uv + vec2(SCREEN_PIXEL_SIZE.x * half_scale_ceil, -SCREEN_PIXEL_SIZE.y * half_scale_floor);
	vec2 top_left_UV =  uv + vec2(-SCREEN_PIXEL_SIZE.x * half_scale_floor, SCREEN_PIXEL_SIZE.y * half_scale_ceil);

	// Sample Normals

	vec3 normal0 = texture(NORMAL_TEXUTRE, bottom_left_UV).rgb;
	vec3 normal1 = texture(NORMAL_TEXUTRE, top_right_UV).rgb;
	vec3 normal2 = texture(NORMAL_TEXUTRE, bottom_right_UV).rgb;
	vec3 normal3 = texture(NORMAL_TEXUTRE, top_left_UV).rgb;

	vec3 normal_finite_difference_0 = normal1 - normal0;
	vec3 normal_finite_difference_1 = normal3 - normal2;

	vec3 view_normal = normal0 * 2.0 - 1.0;
	float n_dot_v = 1.0 - dot(view_normal, CAMERA_DIRECTION_WORLD);
	float normal_threshold_01 = (n_dot_v - depth_threshold) / (1.0 - depth_threshold);
	float new_normal_threshold = normal_threshold_01 * depth_normal_threshold_scale + 1.0;

	float edge_normal = sqrt(dot(normal_finite_difference_0, normal_finite_difference_0) + dot(normal_finite_difference_1, normal_finite_difference_1));
	edge_normal = edge_normal > normal_threshold ? 1.0 : 0.0;

	// Sample depth

	float depth0 = texture(DEPTH_TEXUTRE, bottom_left_UV).r;
	float depth1 = texture(DEPTH_TEXUTRE, top_right_UV).r;
	float depth2 = texture(DEPTH_TEXUTRE, bottom_right_UV).r;
	float depth3 = texture(DEPTH_TEXUTRE, top_left_UV).r;

	float depth_finite_difference_0 = depth1 - depth0;
	float depth_finite_difference_1 = depth3 - depth2;

	float edge_depth = sqrt(pow(depth_finite_difference_0, 2) + pow(depth_finite_difference_1, 2)) * 100.0;
	edge_depth = edge_depth > depth_threshold * depth0 * new_normal_threshold ? 1.0 : 0.0;

	// Combination
	float edge = max(edge_depth, edge_normal);
	vec4 col = vec4(edge_color.rgb, edge_color.a * edge);

	// Apply to screen
	ALBEDO = mix(texture(SCREEN_TEXTURE, uv), col, col.a).rgb;
}