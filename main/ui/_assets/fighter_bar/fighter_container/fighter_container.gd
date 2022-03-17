extends Container

export var regular_style: Resource
export var select_style: Resource
export var point_time := 0.125

var hp_int: int setget set_hp_int
var mp_int: int  setget set_mp_int

func set_hp_int(new_hp):
	hp_int = new_hp
	$HP/Label.text = str(hp_int)

func set_mp_int(new_mp):
	mp_int = new_mp
	$MP/Label.text = str(mp_int)

var buff_icons := {
	"def1": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/defense_buff_icon1.png"),
	"def2": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/defense_buff_icon2.png"),
	"def-1": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/defense_debuff_icon1.png"),
	"def-2": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/defense_debuff_icon2.png"),
	
	"atk1": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/attack_buff_icon1.png"),
	"atk2": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/attack_buff_icon2.png"),
	"atk-1": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/attack_debuff_icon1.png"),
	"atk-2": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/attack_debuff_icon2.png"),
	
	"hit_eva1": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/acc_eva_buff_icon1.png"),
	"hit_eva2": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/acc_eva_debuff_icon2.png"),
	"hit_eva-1": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/acc_eva_debuff_icon1.png"),
	"hit_eva-2": preload("res://main/ui/_assets/fighter_bar/fighter_container/buff_icons/acc_eva_debuff_icon2.png"),
	}

var status_icons = {
	"panic": preload("res://main/ui/_assets/fighter_bar/fighter_container/status_icons/status_icons3.png"),
	"rot": preload("res://main/ui/_assets/fighter_bar/fighter_container/status_icons/status_icons2.png"),
	"dead": preload("res://main/ui/_assets/fighter_bar/fighter_container/status_icons/status_icons4.png")
	}

func set_selected(selected: bool) -> void:
	if selected:
		$Select/SelectBackground.add_stylebox_override("panel", select_style)
	else:
		$Select/SelectBackground.add_stylebox_override("panel", regular_style)

func initialize(fighter: Node) -> void:
	$Name.text = fighter.save_id
	fighter.connect("update_points", self, "update_points", [fighter])
	fighter.connect("selected", self, "set_selected")
	$HP/TextureProgress.max_value = fighter.max_hp
	$MP/TextureProgress.max_value = fighter.max_mp
	$HP/TextureProgress.value = fighter.hp
	$MP/TextureProgress.value = fighter.mp
	hp_int = fighter.hp
	mp_int = fighter.mp
	$HP/Label.text = str(hp_int)
	$MP/Label.text = str(mp_int)
	if !$Tween.is_inside_tree():
		yield($Tween, "tree_entered")
	update_points(fighter)

func update_points(fighter: Node) -> void:
	hp_int = max(0, int($HP/Label.text))
	mp_int = max(0, int($MP/Label.text))
	
	$HP/TextureProgress.max_value = fighter.max_hp
	$MP/TextureProgress.max_value = fighter.max_mp
	
	$Tween.interpolate_property($HP/TextureProgress, "value", null, fighter.hp, point_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MP/TextureProgress, "value", null, fighter.mp, point_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	$Tween.interpolate_property(self, "hp_int", null, fighter.hp, point_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "mp_int", null, fighter.mp, point_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	for child in $Buffs.get_children():
		child.queue_free()
	
	for buff_type in ["atk", "def", "hit_eva"]:
		if fighter.get(buff_type) != 0:
			var new_icon := TextureRect.new()
			new_icon.texture = buff_icons[ buff_type + str(fighter.get(buff_type)) ]
			$Buffs.add_child(new_icon)
	
	if fighter.status == "ok":
		$Name/StatusIcon.visible = false
	else:
		$Name/StatusIcon.visible = true
		$Name/StatusIcon.texture = status_icons[fighter.status]
	
	$Tween.start()
