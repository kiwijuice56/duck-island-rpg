extends KinematicBody2D

export var speed := 128
var dir := Vector2()
var steps := 255.0

onready var transition = get_tree().get_root().get_node("Main/Transition")
onready var combat_ui = get_tree().get_root().get_node("Main/CombatUI/Combat")
onready var overworld_ui = get_tree().get_root().get_node("Main/OverworldUI/Overworld")
onready var cycle = get_tree().get_root().get_node("Main/Combat/PressTurnCycle")
onready var encounter_meter = overworld_ui.get_node("EncounterRate")

var room
var water_tiles
var encounter_type_tiles
var encounter_rate_tiles
var encounter

func _ready() -> void:
	$Area2D.connect("area_entered", self, "area_entered")
	get_tree().get_root().get_node("Main/Combat/PressTurnCycle").connect("battle_ended", self, "battle_ended")
	disable()

func area_entered(area: Area2D) -> void:
	pass

func battle_started() -> void:
	call_deferred("disable")
	yield(transition.transition_in(), "completed")
	
	var enemies = []
	for i in range(0, 1+int(rand_range(encounter.enemy_count_min, encounter.enemy_count_max))):
		var rand = rand_range(0,1)
		var j = -1
		while j != len(encounter.enemies)-1 and rand > 0:
			rand -= encounter.spawn_chances[j]
			j += 1
		enemies.append(encounter.enemies[j])
	cycle.set_enemies(enemies)
	visible = false
	cycle.battle()

func battle_ended() -> void:
	global_position = Vector2(280, 1104)
	visible = true
	$Camera2D.current = true
	call_deferred("enable")

func disable() -> void:
	set_physics_process(false)
	$Area2D/CollisionShape2D.set_disabled(true)
	overworld_ui.disable()

func enable() -> void:
	set_physics_process(true)
	$Area2D/CollisionShape2D.set_disabled(false)
	overworld_ui.enable()

func get_input() -> void:
	dir = Vector2()
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	dir = dir.normalized()

func set_anim() -> void:
	if dir.y > 0:
		$AnimationPlayer.current_animation = "walk_down"
	elif dir.y < 0:
		$AnimationPlayer.current_animation = "walk_up"
	elif dir.x > 0:
		$AnimationPlayer.current_animation = "walk_right"
	elif dir.x < 0:
		$AnimationPlayer.current_animation = "walk_left"
	else:
		$AnimationPlayer.current_animation = "[stop]"

func jump(pos: Vector2) -> void:
	disable()
	overworld_ui.disable()
	$Tween.interpolate_property(self, "global_position", null, pos, .45)
	$Tween.interpolate_property($Sprite, "position", null, $Sprite.position - Vector2(0, 64), 0.25, Tween.TRANS_QUAD, Tween.EASE_IN)
	
	$Tween.start()
	$Timer.start(0.15)
	yield($Timer, "timeout")
	yield($Tween, "tween_completed")
	$Tween.interpolate_property($Sprite, "position", null, $Sprite.position + Vector2(0, 64), 0.25, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$Tween.interpolate_property($Sprite, "region_rect", null, Rect2(0,0,$Sprite.hframes * 60, 0), 0.09)
	$Tween.start()
	$BigSplash.emitting = true
	$Splash1.playing = true
	MusicPlayer.play_music(MusicPlayer.water)
	yield($Tween, "tween_completed")
	$Timer.start(0.15)
	yield($Timer, "timeout")
	$Tween.interpolate_property($Sprite, "region_rect", null, Rect2(0,0,$Sprite.hframes * 60, 25), 0.015)
	$Tween.start()
	yield($Tween, "tween_completed")
	enable()
	overworld_ui.enable()

func room_loaded() -> void:
	water_tiles = get_tree().get_root().get_node("Main/Overworld").get_child(0).get_node("WaterTiles") 
	encounter_rate_tiles = get_tree().get_root().get_node("Main/Overworld").get_child(0).get_node("EncounterRate") 
	encounter_type_tiles = get_tree().get_root().get_node("Main/Overworld").get_child(0).get_node("EncounterType") 
	room = get_tree().get_root().get_node("Main/Overworld").get_child(0)

func _physics_process(delta):
	var snapped = (Vector2(-16,-16)+global_position).snapped(Vector2(64,64))/64
	if water_tiles and not water_tiles.get_cell( snapped.x, snapped.y)  == -1:
		if not (dir == Vector2() or $SmallSplash.emitting):
			$SmallSplash.emitting = true
			$Splash2.playing = true
		$Sprite.set_region_rect(Rect2(0,0,$Sprite.hframes * 60, 25))
	else:
		$Sprite.set_region_rect(Rect2(0,0,$Sprite.hframes * 60, 40))
	
	if dir != Vector2() and encounter_rate_tiles and room:
		if encounter_rate_tiles.get_cell(snapped.x, snapped.y) == 0:
			steps = 255
		else:
			steps -= room.encounter_steps[encounter_rate_tiles.get_cell(snapped.x, snapped.y)] * delta
		encounter = room.encounters[encounter_type_tiles.get_cell(snapped.x, snapped.y)]
	
	if steps <= 0:
		battle_started()
		steps = 255
	encounter_meter.set_encounter_modulate(steps)
	get_input()
	set_anim()
	move_and_slide(dir*speed)
