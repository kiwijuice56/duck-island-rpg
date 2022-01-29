shader_type canvas_item;

uniform vec2 fragment_number = vec2(20,20);
uniform float dissolve_state : hint_range(0,1) = 1;

void fragment() {
	vec2 pixel_fract = fract(UV * fragment_number);
	float pixel_dist = UV.x*distance(pixel_fract, vec2(0.5, 0.5));
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= step(pixel_dist, dissolve_state);
}