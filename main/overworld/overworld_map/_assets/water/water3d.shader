shader_type spatial;
render_mode unshaded;

uniform float tile_factor = 10.0;
uniform float aspect_ratio = 0.5;

uniform vec2 time_factor = vec2(2.0, 3.0);
uniform vec2 offset_factor = vec2(5.0, 2.0);
uniform vec2 amplitude = vec2(0.05, 0.05);

uniform sampler2D water_text : hint_albedo;
uniform sampler2D water_far_text: hint_albedo;
uniform sampler2D water_far_far_text: hint_albedo;

uniform vec3 cameraPos;

varying vec4 world_pos; 
varying float vertexToCam;

// code for camera from: https://godotengine.org/qa/97300/get-depth-of-3d-point-from-camera-in-shader
void vertex() {
	world_pos = WORLD_MATRIX * vec4(VERTEX, 1.0);  // get coords as world coords
	vertexToCam = distance(world_pos.xyz, cameraPos);
}

void fragment() {
	vec2 tiled_uvs = UV * tile_factor;
	tiled_uvs.y *= aspect_ratio;
	
	vec2 wave_uv_offset;
	wave_uv_offset.x += sin(TIME * time_factor.x + (tiled_uvs.x + tiled_uvs.y) * offset_factor.x);
	wave_uv_offset.y += cos(TIME * time_factor.y + (tiled_uvs.x + tiled_uvs.y) * offset_factor.y);
	
	vec4 t;
	if (vertexToCam > 2.5)
		t = texture(water_far_far_text, tiled_uvs + wave_uv_offset * amplitude);
	else if (vertexToCam > 1.7)
		t = texture(water_far_text, tiled_uvs + wave_uv_offset * amplitude);
	else
		t = texture(water_text, tiled_uvs + wave_uv_offset * amplitude);
	ALBEDO = vec3(t.r, t.g, t.b);
}