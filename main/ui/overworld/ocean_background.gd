extends Control

export var segment_scene: PackedScene
var segments := []
var speed = 18
var bob_speed = 0.002
var time = 0

func _ready():
	for i in range(9):
		var sprite = segment_scene.instance()
		sprite.position.x = i*128 - 5
		sprite.position.y = 467
		segments.append(sprite)
		add_child(sprite)

func _process(delta):
	# offset by 5 due to margin container
	rect_position.y = cos(bob_speed * OS.get_ticks_msec()) * 8 
	for segment in segments:
		segment.position.x -= speed * delta
		if segment.position.x < -133:
			segment.position.x = 1019
