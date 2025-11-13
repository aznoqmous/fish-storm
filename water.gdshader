shader_type spatial;

uniform vec3 water_color: source_color;
uniform vec3 light_foam_color: source_color;
uniform vec3 dark_foam_color: source_color;
uniform sampler2D voronoi_texture;
varying vec2 vVertex;
uniform float voronoi_size;
void vertex() {
	// Called for every vertex the material is visible on.
	float amplitude = 0.3;
	float frequency = 0.3;
	float speed = 1.0;
	float phase = (VERTEX.x + VERTEX.z * 2.0) * frequency + TIME * speed;
	
	VERTEX.y = sin(phase) * amplitude;
	
	//NORMAL = vec3(cos(-TIME * TAU / 10.0 + (VERTEX.x / 3.0)), 0, 0);
	float dx = cos(phase) * amplitude * frequency;
	float dz = cos(phase) * amplitude * frequency;
	//NORMAL = normalize(vec3(-dx, 1.0, -dz));
	//NORMAL = vec3(0, 1, 0);
	vVertex = VERTEX.xz;
}

void fragment() {
	// Called for every pixel the material is visible on.
	float light_foam_mask = texture(voronoi_texture, vVertex * voronoi_size + vec2(TIME, TIME / 2.0) * 0.02).x;
	float dark_foam_mask = texture(voronoi_texture, vVertex * voronoi_size + vec2(voronoi_size, voronoi_size) + vec2(TIME, TIME / 2.0) * 0.01).x;
	dark_foam_mask *= 1.0 - light_foam_mask;
	
	vec3 color = water_color * (1.0 - light_foam_mask) * (1.0 - dark_foam_mask);
	color += light_foam_mask * light_foam_color;
	color += dark_foam_mask * dark_foam_color;
	ALBEDO = color;
}

void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
	DIFFUSE_LIGHT = vec3(1.0);
}
