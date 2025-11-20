shader_type canvas_item;
uniform sampler2DArray textures;
uniform vec2 texture_size;
uniform vec2 screen_size;
uniform float alpha = 1.0;

uniform sampler2D texture_flow_map;
const int sprites = 7;
const int displacement_steps = 5;
const float displacement_power = 5.0;
const float displacement_size = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

float noise(vec2 pos){
	return (sin(pos.x) * cos(pos.y) + 1.0) / 2.0;
}

vec3 hsv_to_rgb(vec3 hsv) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
	return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}

uniform float fsize = 2.0;
void fragment() {
	vec2 size = texture_size / ( 1.0 / fsize) ;
	
	float ratio = screen_size.x / size.x;
	vec2 pos = (UV * 8.0 - vec2(TIME / 10.0)) * ratio * (screen_size / texture_size) / 10.0;
	int index = int(pos.x + floor(pos.y) * 2.0);
	index = int(float(index) + TIME / 5.0 + float(index) / 4.0) % sprites;
	//index = int(fract(float((index + int(pos.x + floor(pos.y))) * 126473)/100.0) * 5.0);
	vec2 puv = fract(pos);
	
	vec3 displacement = texture(texture_flow_map, UV / displacement_size + vec2(float(int(TIME * 8.0) % displacement_steps) / 10.0)).xyz;
	vec2 dpos = displacement.xy * 0.02 * displacement_power;
	vec4 tex = texture(textures, vec3(dpos, float(index)));
	
	vec4 sampled = texture(textures, vec3(puv * (vec2(ratio, ratio * size.y / size.x)) / fsize + dpos, float(index)));
	
	vec3 bg_color = hsv_to_rgb(vec3((TIME) / 60.0, 0.5, 0.7));
	vec3 color = hsv_to_rgb(vec3((TIME + float(index) / float(sprites) * 2.5) / 10.0, 0.5, 0.7));
	COLOR = mix(vec4(bg_color * 0.0, 1.0), sampled * vec4(color * 0.2 *  (abs(sin((TIME + float(index) * 0.5) * TAU / 4.0)) / 2.0 + 1.0), 1.0), sampled.a) * vec4(1.0, 1.0, 1.0, alpha);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
