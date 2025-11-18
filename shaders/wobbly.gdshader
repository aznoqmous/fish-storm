shader_type spatial;
render_mode cull_disabled;
uniform sampler2D texture_albedo;
uniform sampler2D texture_flow_map;
uniform vec3 color: source_color = vec3(1.0);
const int displacement_steps = 10;
const float displacement_power = 1.5;
const float displacement_size = 5.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 displacement = texture(texture_flow_map, UV / displacement_size + vec2(float(int(TIME * 8.0) % displacement_steps) / 10.0)).xyz;
	vec2 pos = UV + displacement.xy * 0.02 * displacement_power;
	vec4 tex = texture(texture_albedo, pos);
    ALBEDO = tex.rgb * color;
    ALPHA = pow(tex.a, 3);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
