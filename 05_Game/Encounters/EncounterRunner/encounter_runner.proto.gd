extends Node

@export var fighting_encounter_1: FightingEncounter
@export var fighting_encounter_2: FightingEncounter

@onready var _encounter_runner: EncounterRunner = %EncounterRunner

func _ready() -> void:
	GameManager.init()
	GameManager.game_type = GameManager.GameType.SOLO
	_encounter_runner.start(fighting_encounter_1, fighting_encounter_2)
