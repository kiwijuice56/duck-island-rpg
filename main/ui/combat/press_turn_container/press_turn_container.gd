extends HBoxContainer

onready var anim := get_node("../../AnimationPlayer")
onready var banner := get_node("../Banner")
onready var shimmer := get_node("../../../ShimmerParticles")
onready var shimmer_sound := get_node("../../../ShimmerSound")
const full_texture_player := preload("res://main/ui/combat/press_turn_container/sprites/press_turn1.png")
const half_texture_player:= preload("res://main/ui/combat/press_turn_container/half_turn_player.tres")
const full_texture_enemy := preload("res://main/ui/combat/press_turn_container/sprites/press_turn4.png")
const half_texture_enemy := preload("res://main/ui/combat/press_turn_container/half_turn_enemy.tres")
const player_banner := preload("res://main/ui/combat/press_turn_container/sprites/banner_player.png")
const enemy_banner := preload("res://main/ui/combat/press_turn_container/sprites/banner_enemy.png")

var last_half := 0

func update_turns(full: int, half: int, is_player: bool) -> void:
	anim.current_animation = "fade_in"
	banner.texture = player_banner if is_player else enemy_banner
	yield(anim, "animation_finished")
	banner.visible = full + half > 0
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for _i in range(full):
		var full_turn = TextureRect.new()
		full_turn.texture = full_texture_player if is_player else full_texture_enemy
		full_turn.size_flags_vertical = SIZE_SHRINK_CENTER
		add_child(full_turn)
	for i in range(half):
		var half_turn = TextureRect.new()
		half_turn.texture = half_texture_player if is_player else half_texture_enemy
		half_turn.size_flags_vertical = SIZE_SHRINK_CENTER
		add_child(half_turn)
		if half > last_half and i == 0:
			shimmer.global_position = half_turn.rect_global_position + Vector2((full+i)*28 + 14, 12)
			shimmer_sound.playing = true
			shimmer.emitting = true
	last_half = half
	anim.current_animation = "fade_out"
