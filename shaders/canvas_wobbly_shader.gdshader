shader_type canvas_item;
uniform sampler2D texture_albedo;
uniform sampler2D texture_flow_map;
uniform vec3 color: source_color = vec3(1.0);
uniform int displacement_steps = 4;
uniform float displacement_power = 2.0;
uniform float displacement_size = 5.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 displacement = texture(texture_flow_map, UV / displacement_size + vec2(float(int(TIME * 8.0) % displacement_steps) / 10.0)).xyz;
	vec2 pos = UV + displacement.xy * 0.02 * displacement_power;
	vec4 tex = texture(texture_albedo, pos);
    COLOR = vec4(tex.rgb * color, tex.a);
}
