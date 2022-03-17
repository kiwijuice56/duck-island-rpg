// https://kidscancode.org/godot_recipes/shaders/blur/
shader_type canvas_item;

uniform float blur_amount : hint_range(0, 5);

void fragment() {
	vec2 new_uv = SCREEN_UV + vec2(sin(TIME)/150.0, 0.0);
	COLOR = textureLod(SCREEN_TEXTURE, new_uv, blur_amount);
}