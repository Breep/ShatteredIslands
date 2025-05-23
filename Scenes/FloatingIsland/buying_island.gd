class_name BuyingIsland
extends FloatingIsland

@export var _buying_area: BuyingArea

# ============================== Public functions ==============================

# Spawn all characters on the FightingArea according to the battle
# Connect all characters to the FightingArea of the FloatingIsland
func start_buying_phase(characters: Array[Character], battle_type: Battle.BattleType) -> void:
	pass


func set_active() -> void:
	_center_point_camera.set_active()


func set_inactive() -> void:
	_center_point_camera.set_inactive()
