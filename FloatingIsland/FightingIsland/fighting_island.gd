class_name FightingIsland
extends FloatingIsland

# ============================== Network export ==============================

@export_group("Network")
var _player_owner_id: int = -1
@export var player_owner_id: int = -1:
	get: return _player_owner_id
	set(value):
		if _player_owner_id == value: return
		_player_owner_id = value
		_update_player_ref(_player_owner_id)


# ============================== local node ==============================

@export_group("Local Nodes")
@export var _fighting_area: FightingArea
@export var _camera: Camera3D

# ============================== private variables ==============================

var _current_characters: Array[Character]

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_player_ref(_player_owner_id)

# ============================== Public functions ==============================

# Spawn all characters on the FightingArea according to the battle
# Connect all characters to the FightingArea of the FloatingIsland
func start_fight(characters: Array[Character], battle_type: Battle.BattleType, battle_id: int = -1) -> void:
	_fighting_area.start_fight(characters, battle_type, battle_id)
	_current_characters = characters
	for character in _current_characters:
		character.set_lookat_camera(_camera)


func set_active() -> void:
	if _is_active: return
	_is_active = true
	_fighting_area.set_active()
	_center_point_camera.set_active()
	for character in _current_characters:
		character.on_active_island()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	_fighting_area.set_inactive()
	_center_point_camera.set_inactive()
	for character in _current_characters:
		character.on_inactive_island()

# ============================== Private functions ==============================

func _update_player_ref(player_id: int) -> void:
	if PlayerManager.players.has(player_id):
		PlayerManager.players[player_id].fighting_island = self
