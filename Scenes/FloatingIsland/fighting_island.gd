class_name FightingIsland
extends FloatingIsland

# ============================== local node ==============================

@export var _fighting_area: FightingArea

# ============================== Node base functions ==============================

func _ready() -> void:
	_register_self_in_shared()

# ============================== Public functions ==============================

# Spawn all characters on the FightingArea according to the battle
# Connect all characters to the FightingArea of the FloatingIsland
func start_fight(characters: Array[Character], battle_type: Battle.BattleType) -> void:
	_fighting_area.start_fight(characters, battle_type)


func set_active() -> void:
	_fighting_area.set_active()
	_center_point_camera.set_active()


func set_inactive() -> void:
	_fighting_area.set_inactive()
	_center_point_camera.set_inactive()

# ============================== Private functions ==============================

func _register_self_in_shared() -> void:
	pass
