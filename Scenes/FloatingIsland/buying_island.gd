class_name BuyingIsland
extends FloatingIsland

@export var _buying_area: BuyingArea

# ============================== Public functions ==============================

# Spawn all characters on the BuyingArea according to the battle
func start_buying_phase(battles: Array[Battle]) -> void:
	_buying_area.start_round(battles)


func set_active() -> void:
	if _is_active: return
	_is_active = true
	_center_point_camera.set_active()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	_center_point_camera.set_inactive()
