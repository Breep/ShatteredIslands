extends Node3D

@export var island: FightingIsland

@export var left_formation: FightingFormation
@export var right_formation: FightingFormation

func _ready() -> void:
	GameManager.init()
	
	if island == null:
		printerr("No island set")
		return
	
	island.init_fight_3(left_formation.mirrored().force_team(1), right_formation.force_team(2))
	island.set_active()
	GlobalFightingManager.start()
	
