extends VBoxContainer

export var point_time := 0.125

var hp_int: int setget set_hp_int
var mp_int: int setget set_mp_int

func set_hp_int(new_hp_int: int) -> void:
	hp_int = new_hp_int
	$HP/Label.text = str(hp_int)

func set_mp_int(new_mp_int: int) -> void:
	mp_int = new_mp_int
	$MP/Label.text = str(mp_int)

func initialize(fighter: Node) -> void:
	$Name.text = fighter.save_id
	$HP/TextureProgress.max_value = fighter.max_hp
	$MP/TextureProgress.max_value = fighter.max_mp
	$HP/TextureProgress.value = fighter.hp
	$MP/TextureProgress.value = fighter.mp
	hp_int = fighter.hp
	mp_int = fighter.mp
	$HP/Label.text = str(hp_int)
	$MP/Label.text = str(mp_int)

func update_points(fighter: Node) -> void:
	hp_int = int($HP/Label.text)
	mp_int = int($MP/Label.text)
	$Tween.interpolate_property($HP/TextureProgress, "value", null, fighter.hp, point_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MP/TextureProgress, "value", null, fighter.mp, point_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	$Tween.interpolate_property(self, "hp_int", null, fighter.hp, point_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "mp_int", null, fighter.mp, point_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	$Tween.start()
