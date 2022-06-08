extends Camera2D

export var cam_radius := 1024
export var speed := 25

var vel := Vector2()

func _process(delta) -> void:
	vel = Vector2()
	if Input.is_action_pressed("ui_left"):
		vel.x -= 1
	if Input.is_action_pressed("ui_right"):
		vel.x += 1
	if Input.is_action_pressed("ui_up"):
		vel.y -= 1
	if Input.is_action_pressed("ui_down"):
		vel.y += 1
	vel = vel.normalized() * delta * speed
	position += vel
	if position.length() >= cam_radius:
		position = cam_radius * position.normalized()
	position.x = round(position.x)
	position.y = round(position.y)
