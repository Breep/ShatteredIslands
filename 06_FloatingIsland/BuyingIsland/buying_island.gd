class_name BuyingIsland
extends FloatingIsland

# ============================== Local nodes ==============================

@export var _buying_area: BuyingArea
@export var _camera: Camera3D
@export var _clicker_module: ClickerModule

# ============================== Private variables ==============================

var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public functions ==============================

func cleanup() -> void:
	_buying_area.cleanup()


# === Old API (à supprimer une fois la nouvelle validée) ===
# Spawn all heroes on the BuyingArea according to the battle
func start_buying_phase(battles: Array[Battle]) -> void:
	_buying_area.start_round(battles)


# === New API: populate from a TavernEncounter, injecting the player's hero / acolytes ===
func start_buying_phase_from_encounter(encounter: TavernEncounter, hero_scene: PackedScene, acolyte_scenes: Array[PackedScene]) -> void:
	_buying_area.start_round_from_encounter(encounter, hero_scene, acolyte_scenes)


func set_active() -> void:
	if _is_active: return
	_is_active = true
	_camera.make_current()
	_buying_area.set_active()
	_clicker_module.set_active()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	_buying_area.set_inactive()
	_clicker_module.set_inactive()
