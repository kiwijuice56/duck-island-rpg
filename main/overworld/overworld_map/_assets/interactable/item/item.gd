extends Interactable
class_name Item

export var item: PackedScene
export var item_name := ""
export(int, 1, 99) var count := 1

export var light_beam: PackedScene
var emitting_light := false


func _ready() -> void:
	set_process(false)
	$Timer.connect("timeout", self, "shine_light")
	$CPUParticles2D.emitting = true
	emitting_light = true
	shine_light()

func _input(event):
	if not disabled and not overworld_ui.open and Input.is_action_just_pressed("ui_accept"):
		call_deferred("talk", body)

func body_entered(body) -> void:
	self.body = body
	disabled = false
	overworld_ui.display_prompt("Pick up: Z")

func body_exited(body) -> void:
	body = null
	disabled = true
	overworld_ui.hide_prompt()

func shine_light():
	if not emitting_light:
		return
	for i in range(randi() % 6):
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
	$Tween.interpolate_property(overworld_ui.get_node("TextBox"), "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.2)
	$Tween.start()
	yield($Tween, "tween_completed")
	yield(overworld_ui.get_node("TextBox").display_convo("You got x%d %s!" % [item_name, count]), "completed")
	emitting_light = true
	shine_light()
	$Tween.interpolate_property(overworld_ui.get_node("TextBox"), "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2)
	$Tween.start()
	yield($Tween, "tween_completed")
	emitting_light = false
	player.enable()
