shader_type canvas_item;

uniform sampler2D texture_flow_map;
uniform vec3 color: source_color = vec3(1.0);
uniform int displacement_steps = 3;
uniform float displacement_power = 300.0;
uniform float displacement_size = 600.0;

void vertex() {
	// Called for every vertex the material is visible on.
	vec3 displacement = texture(texture_flow_map, VERTEX / displacement_size + vec2(float(int(TIME * 8.0) % displacement_steps) / 10.0)).xyz;
	vec2 pos = VERTEX + displacement.xy * 0.02 * displacement_power;
	VERTEX = pos;
}
void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
