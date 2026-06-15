extends Node3D

@export var island: FightingIsland

@export var left_formation: FightingFormation
@export var right_formation: FightingFormation

func _ready() -> void:
	GameManager.init()
	
	if island == null:
		printerr("No island set")
		return
	
	# mirrored() supprimé : la formation gauche n'est plus miroir-ée ici.
	island.init_fight(left_formation, right_formation, 1, 2)
	island.set_active()
	GlobalFightingManager.start()
	
