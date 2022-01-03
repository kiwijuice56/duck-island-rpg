extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	self.global_position = get_global_mouse_pos()
	
	
	
	if $AudioStreamPlayer.playing == flase:
		$AudioStreamPlayer.play()
	pass
	
