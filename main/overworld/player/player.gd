extends KinematicBody2D

var sand_step_sounds := []
var wood_step_sounds := []

export var encounters_enabled := false
export var speed := 105
export var max_inertia := 16.0
export var inertia_change := 2.0
var dir := Vector2()
var last_dir := Vector2()
var inertia := 0.0
var steps := 255.0

onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var combat_ui = get_tree().get_root().get_node("Main//ViewportContainer/Viewport/UI/CombatUI/Combat")
onready var overworld_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/OverworldUI/Overworld")
onready var cycle = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Combat/PressTurnCycle")
onready var encounter_meter = overworld_ui.get_node("EncounterRate")

signal menu_opened

var room: Node
var encounter_type_tiles: TileMap
var encounter_rate_tiles: TileMap
var floor_style_tiles: TileMap
var encounter: Resource

func _ready() -> void:
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Combat/PressTurnCycle").connect("battle_ended", self, "battle_ended")
	disable()
	sand_step_sounds = get_wav_files("res://main/overworld/world_building/floor_style/step_sounds/sand/")
	wood_step_sounds = get_wav_files("res://main/overworld/world_building/floor_style/step_sounds/wood/")

func get_wav_files(path: String) -> Array:
	var arr := []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav"):
				arr.append(load(path + file_name))
			file_name = dir.get_next()
	return arr

# update transition's camera and start the actual battle
func battle_started() -> void:
	call_deferred("disable")
	$AnimationPlayer.call_deferred("set_current_animation", "[stop]")
	$Timer.start(.35)
	$Tween.interpolate_property($Camera2D, "zoom", null, Vector2(.25, .25), .45, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	SoundPlayer.play_sound(SoundPlayer.battle_woosh)
	yield($Timer, "timeout")
	yield(transition.transition_in(), "completed")
	$Camera2D.zoom = Vector2(1, 1)
	visible = false
	cycle.set_enemies(room.get_enemies(encounter))
	cycle.battle()

func battle_ended() -> void:
	steps = 255.0
	visible = true
	$Camera2D.current = true
	call_deferred("enable")

func disable() -> void:
	set_physics_process(false)
	$AnimationPlayer.current_animation = "[stop]"
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

func jump(pos: Vector2, in_water: bool) -> void:
	$AnimationPlayer.current_animation = "[stop]"
	disable()
	overworld_ui.disable()
	
	# change sprite rect to out of water
	if not in_water:
		$Tween.interpolate_property($Sprite, "region_rect", null, Rect2(0,0,$Sprite.hframes * 60, 40), 0.015)
	
	# jump out
	$Tween.interpolate_property(self, "global_position", null, pos, .45)
	$Tween.interpolate_property($Sprite, "position", null, $Sprite.position - Vector2(0, 64), 0.25, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	$Timer.start(0.15)
	yield($Timer, "timeout")
	yield($Tween, "tween_completed")
	
	# jump in
	$Tween.interpolate_property($Sprite, "position", null, $Sprite.position + Vector2(0, 64), 0.25, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	
	# change music
	if in_water:
		
		MusicPlayer.play_music(MusicPlayer.water)
	else:
		room.get_parent().play_room_music() # overworld_map
	
	# create splashing inside of water animation
	if in_water:
		$Tween.interpolate_property($Sprite, "region_rect", null, Rect2(0,0,$Sprite.hframes * 60, 0), 0.09)
		$Tween.start()
		yield($Tween, "tween_completed")
		$FloorStyling/BigSplash.emitting = true
		$FloorStyling/Splash1.playing = true
		$Timer.start(0.15)
		yield($Timer, "timeout")
		$Tween.interpolate_property($Sprite, "region_rect", null, Rect2(0,0,$Sprite.hframes * 60, 25), 0.015)
		$Tween.start()
		yield($Tween, "tween_completed")
	
	$Timer.start(0.5)
	yield($Timer, "timeout")
	enable()
	overworld_ui.enable()

# update instance variables to have access to room 
func room_loaded() -> void:
	encounter_rate_tiles = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld").get_child(0).get_node("EncounterRate") 
	encounter_type_tiles = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld").get_child(0).get_node("EncounterType") 
	floor_style_tiles = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld").get_child(0).get_node("FloorStyleType") 
	room = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld").get_child(0)

# handles contant floor code, sprite and other visuals on different tiles
func handle_floor(delta: float) -> void:
	var snapped = (Vector2(-16,-16)+global_position).snapped(Vector2(64,64))/64
	
	if dir != Vector2() and encounter_rate_tiles and room:
		if encounter_rate_tiles.get_cell(snapped.x, snapped.y) == 0:
			steps = 255.0
		elif encounters_enabled:
			steps -= 4*room.encounter_steps[encounter_rate_tiles.get_cell(snapped.x, snapped.y)] * delta
			encounter = room.encounters[encounter_type_tiles.get_cell(snapped.x, snapped.y)]
	# this can be reworked once there is jumpers to outside of the water
	if floor_style_tiles and floor_style_tiles.get_cell(snapped.x, snapped.y) == 2:
		$Sprite.set_region_rect(Rect2(0,0,$Sprite.hframes * 60, 25))
	else:
		$Sprite.set_region_rect(Rect2(0,0,$Sprite.hframes * 60, 40))

# called during animation to have timed step sounds and particles
func step() -> void:
	if not floor_style_tiles:
		return
	var snapped := (Vector2(-16,-16)+global_position).snapped(Vector2(64,64))/64
	
	if not $FloorStyling/Sand.playing and floor_style_tiles.get_cell(snapped.x, snapped.y) == 0:
		$FloorStyling/Sand.stream = sand_step_sounds[randi() % len(sand_step_sounds)]
		$FloorStyling/Sand.playing = true
		if randf() > 0.33:
			$FloorStyling/SandSplash.emitting = true
	elif not $FloorStyling/Wood.playing and floor_style_tiles.get_cell(snapped.x, snapped.y) == 1:
		$FloorStyling/Wood.stream = wood_step_sounds[randi() % len(wood_step_sounds)]
		$FloorStyling/Wood.playing = true
	elif not $FloorStyling/Splash2.playing and floor_style_tiles.get_cell(snapped.x, snapped.y) == 2:
		$FloorStyling/SmallSplash.emitting = true
		$FloorStyling/Splash2.playing = true
		if randf() > 0.33:
			$FloorStyling/SmallSplash.emitting = true

func _physics_process(delta: float) -> void:
	handle_floor(delta)
	if steps <= 0:
		battle_started()
		set_physics_process(false)
		steps =  0.0
	get_input()
	set_anim()
	
	if not dir:
		inertia -= inertia_change
	else:
		last_dir = dir
		inertia += inertia_change
	
	inertia = max(0, min(max_inertia, inertia))
	var vel := (last_dir if not dir and inertia > 0 else dir) * (speed + inertia)
	move_and_slide(vel)
	position.x = round(position.x)
	position.y = round(position.y)

func _process(_delta):
	encounter_meter.set_encounter_modulate(steps)
