class_name TavernCenter
extends Node3D

# ============================== Local nodes ==============================

@export_group("Local nodes")
@export var _encounter_display: EncounterDisplay

# ============================== Public functions ==============================

func display_encounter(encounter: TavernEncounter) -> void:
	# On nettoie d'abord les entités du round précédent, puis on place les nouvelles.
	_encounter_display.cleanup()
	_encounter_display.display(encounter)


func cleanup() -> void:
	_encounter_display.cleanup()
