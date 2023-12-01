shader_type spatial;

uniform vec4 background_color : source_color = vec4( 0.0, 0.0, 0.0, 1.0 );
uniform vec4 line_color : source_color = vec4( 0.0, 1.0, 1.0, 1.0 );
uniform float line_freq = 9.56;
uniform float height = 0.6;
uniform float speed = 0.8;
uniform float width = 11.0;
uniform vec3 scale = vec3( 2.0, 16.0, 100.0);
uniform vec3 offset = vec3( 2.0, 16.0, 100.0);

varying vec3 normal;

void vertex() {
  normal = NORMAL;
  UV *= vec2(3.0, 2.0);
}

void fragment(){
  vec2 uv = UV * scale.xy + offset.xy;
  if (normal.x > 0.9) {
    uv.x = - UV.y * scale.z + offset.z;
    uv.y = UV.x * scale.y + offset.y;
  }
  float shift = cos( floor( uv.y ) );
  uv.x += shift;

  float freq = clamp( cos( uv.x * line_freq ) * 3.0, 0.0, 1.0 ) * height;
  float line = 1.0 - clamp( abs( freq - mod( uv.y, 1.0 ) ) * width, 0.0, 1.0 );

  vec4 c = mix( background_color, line_color, line * mod( uv.x - TIME * speed * abs( shift ), 1.0 ) /*  * mod( TIME + shift, 1.0 ) */ );

  if (abs(normal.z) > 0.9) {
    ALBEDO = background_color.rgb;
  } else {
    ALBEDO = c.rgb;
    EMISSION = c.rgb;
  }
}