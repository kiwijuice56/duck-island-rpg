extends Node

export(String, MULTILINE) var event_text: String
onready var overworld_text_box := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/OverworldUI/Overworld/TextBox")

signal event_complete

func _ready() -> void:
	# add empty padding event for transitions to work properly
	event_text += "\n#fill\n1\n"

func play(actors: Array, text_box: Node = null) -> void:
	if text_box == null:
		text_box = overworld_text_box
	var event_index := 0
	var last_type := ""
	var events = parse_cutscene_text(event_text)
	while event_index < len(events):
		var e: Array = events[event_index]
		var next_index: int = int(e[1])
		
		if e[0] in ["talk", "bin_choice"] and not last_type in ["talk", "bin_choice"]: 
			text_box.clear_text()
			$Tween.interpolate_property(text_box, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.2)
			$Tween.start()
			yield($Tween, "tween_completed")
		if not e[0] in ["talk", "bin_choice"] and last_type in ["talk", "bin_choice"]: 
			$Tween.interpolate_property(text_box, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2)
			$Tween.start()
			yield($Tween, "tween_completed")
		
		match e[0]:
			"talk":
				yield(talk(e, text_box), "completed")
			"bin_choice":
				next_index = yield(bin_choice(e, text_box), "completed")
			"movie":
				var movie_scene = load(e[2]).instance()
				add_child(movie_scene)
				yield(movie_scene, "finished")
				movie_scene.queue_free()
			"anim":
				actors[int(e[2])].get_node("AnimationPlayer").current_animation = e[3]
				yield(actors[int(e[2])].get_node("AnimationPlayer"), "animation_finished")
			"cam": pass
			"img": pass
		event_index += next_index
		last_type = e[0]
		emit_signal("event_complete")

# talk
# {goto}
# {speaker}
# {text}
# @sec_par_char: float
# @after_delay: float
# @require_press: bool
func talk(e: Array, text_box) -> void:
	var speaker = e[2]
	var text = e[3]
	var sec_per_char = float(e[4]) if 4 < len(e) and len(e[4]) > 0 else 0.02
	var after_delay = float(e[5]) if 5 < len(e) and len(e[5]) > 0 else 0.0
	var require_press = bool(e[6]) if 6 < len(e) and len(e[6]) > 0 else true
	
	text_box.clear_text()
	yield(text_box.display_text(text, sec_per_char, after_delay, require_press, speaker), "completed")

# bin_choice
# {goto 1}
# {goto 2}
# {speaker}
# {text}
# {choice 1}
# {choice 2}
# @sec_par_char: float
# @after_delay: float
func bin_choice(e: Array, text_box) -> int:
	var speaker = e[3]
	var text = e[4]
	var choices := [e[5], e[6]]
	var sec_per_char = float(e[7]) if 7 < len(e) and len(e[4]) > 0 else 0.02
	var after_delay = float(e[8]) if 8 < len(e) and len(e[5]) > 0 else 0.0
	
	text_box.clear_text()
	var choice = yield(text_box.display_choices(text, choices, sec_per_char, after_delay), "completed")
	
	return int(e[1] if choice == choices[0] else e[2])

func parse_cutscene_text(s: String) -> Array:
	var lines := s.split("\n")
	var events := []
	var last_event: Array
	for line in lines:
		if line.strip_edges() == "":
			events.append(last_event)
			last_event = []
		elif line.begins_with("#"):
			last_event = [line.substr(1).strip_edges()]
		else:
			last_event.append(line.strip_edges())
	return events
