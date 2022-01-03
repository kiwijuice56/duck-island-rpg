extends KinematicBody2D

export var speed := 128
var dir := Vector2()

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


func _physics_process(delta):
	get_input()
	set_anim()
	print(dir*speed)
	move_and_slide(dir*speed)
