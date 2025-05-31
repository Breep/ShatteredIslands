class_name BuyingIsland
extends FloatingIsland

# ============================== Signals ==============================

signal buying_phase_finished()

# ============================== Local nodes ==============================

@export var _buying_area: BuyingArea

# ============================== Node base functions ==============================

func _ready() -> void:
	_buying_area.buying_phase_finished.connect(_on_buying_area_buying_phase_finished)

# ============================== Public functions ==============================

# Spawn all characters on the BuyingArea according to the battle
func start_buying_phase(battles: Array[Battle]) -> void:
	_buying_area.start_round(battles)


func set_active() -> void:
	if _is_active: return
	_is_active = true
	_center_point_camera.set_active()
	_buying_area.set_active()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	_center_point_camera.set_inactive()
	_buying_area.set_inactive()

# ============================== Callbacks ==============================

func _on_buying_area_buying_phase_finished() -> void:
	buying_phase_finished.emit()
