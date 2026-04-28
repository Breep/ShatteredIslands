class_name Tavern
extends Node3D

@export_group("External Nodes")
@export var _tarven_center: TavernCenter


func display_encounter(encounter: TavernEncounter) -> void:
	_tarven_center.display_encounter(encounter)


func cleanup() -> void:
	_tarven_center.cleanup()
