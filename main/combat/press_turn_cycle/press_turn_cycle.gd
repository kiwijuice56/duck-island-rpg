extends "res://addons/rpg_framework/custom_nodes/fighter_cycle/team_cycle/team_cycle.gd"

onready var combat_ui := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/CombatUI/Combat")
onready var after_battle := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/AfterBattleUI/AfterBattle")
onready var text_box = combat_ui.get_node("VBoxContainer/TextBox")
onready var press_turn_container := combat_ui.get_node("VBoxContainer/Top/PressTurnContainer")
onready var cam := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/MainCamera")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")

signal battle_ended

func set_enemies(enemies: Array) -> void:
	for child in $EnemyParty.get_children():
		$EnemyParty.remove_child(child)
		child.queue_free()
	for enemy in enemies:
		var new_enemy = enemy.instance()
		$EnemyParty.add_child(new_enemy)

func position_fighters() -> void:
	for i in range($PlayerParty.get_child_count()):
		$PlayerParty.get_child(i).global_position = get_node("../Positions").get_child($PlayerParty.get_child_count()-1).get_child(i).global_position
		$PlayerParty.get_child(i).global_position.x -= 200
	for i in range($EnemyParty.get_child_count()):
		$EnemyParty.get_child(i).global_position = get_node("../Positions").get_child($EnemyParty.get_child_count()-1).get_child(i).global_position
		$EnemyParty.get_child(i).global_position.x += 200

func compare_fighters(a, b) -> bool:
	return a.agility > b.agility

func update_cycle() -> Array:
	cycle = []
	var fighter_script : Script = load("res://addons/rpg_framework/custom_nodes/fighter/fighter.gd")
	var party_script : Script = load("res://addons/rpg_framework/custom_nodes/party/party.gd")
	for party in get_children():
		if not party is party_script:
			continue
		var party_cycle: Array = []
		for fighter in party.get_children():
			if fighter.status == "dead":
				continue
			if not fighter is fighter_script:
				continue
			if not fighter.is_connected("tree_exited", self, "remove_fighter_from_cycle"):
				fighter.connect("tree_exited", self, "remove_fighter_from_cycle", [fighter])
			party_cycle.append(fighter)
			party_cycle.sort_custom(self, "compare_fighters")
		cycle.append(party_cycle)
	return cycle

# doesn't resort, just pops dead members
func clean_cycle() -> void:
	var new_cycle := []
	for sub in cycle:
		var new_sub_cycle := []
		for fighter in sub:
			if fighter.status != "dead":
				new_sub_cycle.append(fighter)
		new_cycle.append(new_sub_cycle)
	cycle = new_cycle

func battle_end() -> void:
	yield(transition.transition_in(), "completed")
	after_battle.visible = true
	after_battle.last = self
	after_battle.last_func = "switch_to_overworld"
	after_battle.show_info(0, 0, [])
	combat_ui.visible = false
	yield(transition.transition_out(), "completed")
	after_battle.enable()

func switch_to_overworld() -> void:
	cam.current = false
	after_battle.disable()
	MusicPlayer.play_music(MusicPlayer.island)
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld").visible = true
	for child in get_children():
		for fighter in child.get_children():
			fighter.get_node("Sprite").visible = false
	emit_signal("battle_ended")
	yield(transition.transition_out(), "completed")

func battle() -> void:
	MusicPlayer.play_music(MusicPlayer.battle)
	combat_ui.visible = true
	cam.current = true
	position_fighters()
	for child in get_children():
		for fighter in child.get_children():
			fighter.status = "ok"
			fighter.update_status()
			fighter.get_node("Sprite").frame = 0
			fighter.get_node("Sprite").modulate = Color(1,1,1,1)
			if fighter.get_node("SpriteAnimationPlayer").has_animation("idle"):
				fighter.get_node("SpriteAnimationPlayer").current_animation = "idle"
			fighter.atk = 0
			fighter.def = 0
			fighter.hit_eva = 0
			fighter.hp = fighter.max_hp
			fighter.mp = fighter.max_mp
			fighter.emit_signal("update_points")
			fighter.get_node("Sprite").visible = true
	cam.fit($EnemyParty.get_children(), 0, -125)
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld").visible = false
	text_box.display_text("", 0, 0)
	press_turn_container.update_turns(0, 0)
	yield(transition.transition_out(), "completed")
	text_box.display_text("Enemies approach!", 0.02, .7)
	yield(cam.fit($EnemyParty.get_children(), 2, -175), "completed")
	while true:
		update_cycle()
		switch_sub_cycle()
		for _i in range(get_child_count()):
			yield(combat_ui.set_turn_label("player_turn" if sub_cycle[0].get_parent() == $PlayerParty else "enemy_turn"), "completed")
			var full_turns := len(sub_cycle)
			var half_turns := 0
			
			yield(press_turn_container.update_turns(full_turns, half_turns), "completed")
			while full_turns + half_turns > 0: 
				var report: Dictionary = yield(start_next_fighter(), "completed")
				
				clean_cycle()
				for sub in cycle:
					if len(sub) == 0:
						MusicPlayer.play_music(MusicPlayer.victory)
						yield(text_box.display_text("Battle end.", 0.02, 1.5), "completed")
						battle_end()
						return
				
				match report["success"]:
					-1:
						SoundPlayer.play_sound(SoundPlayer.glass_break)
						for i in range(2):
							if half_turns > 0:
								half_turns -= 1
							elif full_turns > 0:
								full_turns -= 1
					0:
						if half_turns > 0:
							half_turns -= 1
						else:
							full_turns -= 1
					1:
						if half_turns > 0:
							half_turns -= 1
						else:
							full_turns -= 1
							half_turns += 1
					2:
						if full_turns > 0:
							full_turns -= 1
							half_turns += 1
						else:
							half_turns -= 1
				yield(press_turn_container.update_turns(full_turns, half_turns), "completed")
			switch_sub_cycle()
