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
var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_player_ref(_player_owner_id)
	if _player_owner_id != -1:
		Events.signal_fighting_island_spawned(self, _player_owner_id)
	Events.game_state_changed.connect(_on_events_game_state_changed)

# ============================== Public functions ==============================

# Spawn all characters on the FightingArea according to the battle
# Connect all characters to the FightingArea of the FloatingIsland
func start_fight(characters: Array[Character], battle_type: Battle.BattleType, battle_id: int = -1) -> void:
	print("FightingIsland: Starting a fight : ", battle_id)
	_fighting_area.start_fight(characters, battle_type, battle_id)
	_current_characters = characters
	for character in _current_characters:
		character.set_lookat_camera(_camera)
	_force_local_player_camera_on_island()


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

func _force_local_player_camera_on_island() -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server(): return
	if _current_characters.is_empty(): return
	for character in _current_characters:
		if character.player == PlayerManager.get_local_player():
			Shared.scene_switcher.set_island_active_only(self)


func _update_player_ref(player_id: int) -> void:
	if PlayerManager.players.has(player_id):
		PlayerManager.players[player_id].fighting_island = self

# ============================== Callback functions ==============================

func _on_events_game_state_changed(game_state: Game.GameState) -> void:
	if game_state == Game.GameState.BUYING:
		_current_characters.clear()


















 
