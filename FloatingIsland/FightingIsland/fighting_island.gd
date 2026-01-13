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

# ============================== private variables ==============================

var _current_heroes: Array[Hero]
var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_player_ref(_player_owner_id)
	if _player_owner_id != -1:
		Events.signal_fighting_island_spawned(self, _player_owner_id)
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

# ============================== Public functions ==============================

# Spawn all heroes on the FightingArea according to the battle
# Connect all heroes to the FightingArea of the FloatingIsland
func init_fight(heroes: Array[Hero], battle_type: Battle.BattleType, battle_id: int = -1) -> void:
	Verbose.debug("Starting a fight | " + str(battle_id), Verbose.Category.FIGHTING_ISLAND)
	_fighting_area.init_fight(heroes, battle_type, battle_id)
	_current_heroes = heroes
	_force_local_player_camera_on_island()


func set_active() -> void:
	show()
	if _is_active: return
	_is_active = true
	_center_point_camera.set_active()


func set_inactive() -> void:
	hide()
	if not _is_active: return
	_is_active = false
	_center_point_camera.set_inactive()


func get_fighting_area() -> FightingArea:
	return _fighting_area

# ============================== Private functions ==============================

func _force_local_player_camera_on_island() -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server(): return
	if _current_heroes.is_empty(): return
	for hero: Hero in _current_heroes:
		if hero.player == PlayerManager.get_local_player():
			Shared.scene_switcher.set_island_active_only(self)


func _update_player_ref(player_id: int) -> void:
	if PlayerManager.players.has(player_id):
		PlayerManager.players[player_id].fighting_island = self

# ============================== Callback functions ==============================

func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	if game_state == GameManager.GameState.BUYING:
		_current_heroes.clear()


















 
