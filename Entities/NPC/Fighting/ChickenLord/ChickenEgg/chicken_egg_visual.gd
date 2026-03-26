extends Node3D

@onready var _egg_full: Node3D = %eggfull

const GIFTED_ENGINEER_EGG: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/ChickenEgg/Visuals/gifted_egg_engineer.tscn")
const GIFTED_ARDENT_CELESTIAL_EGG: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/ChickenEgg/Visuals/gifted_egg_ardent_celestial.tscn")
const GIFTED_COLOSSUS_EGG: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/ChickenEgg/Visuals/gifted_egg_colossus.tscn")

func set_visual(chicken_type: Chicken.Type) -> void:
	match chicken_type:
		Chicken.Type.GIFTED_ENGINEER:
			_egg_full.queue_free()
			add_child(GIFTED_ENGINEER_EGG.instantiate())
		Chicken.Type.GIFTED_ARDENT_CELESTIAL:
			_egg_full.queue_free()
			add_child(GIFTED_ARDENT_CELESTIAL_EGG.instantiate())
		Chicken.Type.GIFTED_COLOSSUS:
			_egg_full.queue_free()
			add_child(GIFTED_COLOSSUS_EGG.instantiate())
