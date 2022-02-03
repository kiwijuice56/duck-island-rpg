extends ItemData
class_name CombatItemData

export(String, "phys","fire", "water", "elec", "wind", "nuclear", "ghost", "buff", "heal") var type := "phys"
export var attached_skill: PackedScene
