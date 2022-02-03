extends Interactable
class_name Item

export var item: Resource
export(int, 1, 99) var count := 1
export var light_beam: PackedScene

onready var item_node = get_tree().get_root().get_node("Main/Items")

var emitting_light := false

func _ready() -> void:
	set_process(false)
	$Timer.connect("timeout", self, "shine_light")

func _input(_event):
	if not disabled and not overworld_ui.open and Input.is_action_just_pressed("ui_accept"):
		call_deferred("collect", body)

func body_entered(body) -> void:
	self.body = body
	disabled = false
	overworld_ui.display_prompt("Pick up: Z")

func body_exited(_body) -> void:
	self.body = null
	disabled = true
	overworld_ui.hide_prompt()

func shine_light():
	if not emitting_light:
		return
	for _i in range(2 + randi() % 3):
		var new_light = light_beam.instance()
		add_child(new_light)
		new_light.rotation_degrees = randi() % 360
	$Timer.start(rand_range(.2, .45))

func collect(player) -> void:
	disabled = true
	overworld_ui.hide_prompt()
	player.disable()
	overworld_ui.get_node("TextBox").label.text = ""
	overworld_ui.get_node("TextBox/HBoxContainer/Icon").visible = false
	# align both cameras to prevent jitter
	cam.global_position = player.get_node("Camera2D").global_position
	cam.pan(self, 0.2, Vector2())
	cam.prioritize([self, player])
	cam.toggle_cover(true)
	$AudioStreamPlayer.playing = true
	$Sprite.texture = item.texture
	$CPUParticles2D.emitting = true
	$Tween.interpolate_property(MusicPlayer, "global_volume", null, MusicPlayer.global_volume-10, 0.2)
	$Tween.interpolate_property(overworld_ui.get_node("TextBox"), "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.2)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.6)
	$Tween.interpolate_property(self, "position", null, position + Vector2(0,-85), 0.8)
	$Tween.start()
	emitting_light = true
	shine_light()
	yield($Tween, "tween_completed")
	yield(overworld_ui.get_node("TextBox").display_text("You got x%d %s!" % [count, item.save_id.capitalize()], 0.02, 3.0), "completed")
	$Tween.interpolate_property(overworld_ui.get_node("TextBox"), "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2)
	$Tween.interpolate_property(self, "position", null, position - Vector2(0,-85), 0.4)
	$Tween.interpolate_property(MusicPlayer, "global_volume", null, MusicPlayer.global_volume+10, 0.2)
	$Tween.start()
	$CPUParticles2D.emitting = false
	cam.deprioritize([self, player])
	cam.toggle_cover(false)
	cam.pan(player, .2, Vector2())
	yield($Tween, "tween_completed")
	emitting_light = false
	player.enable()
	# gets inventory specific to this category of items, then adds this item
	var inventory = item_node.get(item.category + "_items")
	if item in inventory:
		inventory[item] += 1
	else:
		inventory[item] = 1
	queue_free()
