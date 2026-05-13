class_name BuyingArea
extends Node3D

# ============================== Private variables ==============================

var _is_active: bool = false

# ============================== Local nodes ==============================

@onready var _tavern: Tavern = %Tavern_Animated

# ============================== Node base functions ==============================

func _ready() -> void:
	return

# ============================== Public functions ==============================

# === Old API (à supprimer une fois la nouvelle validée) ===
func start_round(battles: Array[Battle]) -> void:
	_tavern.put_tables_according_to_battles(battles)


func cleanup() -> void:
	_tavern.cleanup()


# === New API: relay to Tavern.populate_from_encounter ===
func start_round_from_encounter(encounter: TavernEncounter, hero_scene: PackedScene, acolyte_scenes: Array[PackedScene]) -> void:
	_tavern.populate_from_encounter(encounter, hero_scene, acolyte_scenes)


func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()
