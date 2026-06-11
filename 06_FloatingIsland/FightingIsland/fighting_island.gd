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

var _current_heroes: Array[Entity]
var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_player_ref(_player_owner_id)
	if _player_owner_id != -1:
		Events.signal_fighting_island_spawned(self, _player_owner_id)
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

# ============================== Public functions ==============================

func init_fight(left_formation: FightingFormation, right_formation: FightingFormation, left_team: int, right_team: int) -> void:
	_fighting_area.init_fight(left_formation, right_formation, left_team, right_team)
	_current_heroes = _fighting_area.get_fighting_heroes()
	_force_local_player_camera_on_island()


func set_active() -> void:
	show()
	if _is_active: return
	_is_active = true
	_center_point_camera.set_active()
	_center_point_camera.play_intro()


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
	var local_player: Player = PlayerManager.get_local_player()
	if local_player == null: return

	for hero: Entity in _current_heroes:
		if hero.entity_name == local_player.player_name: # TODO rework cette mosntruosité
			Shared.scene_switcher.set_island_active_only(self)
			break


func _update_player_ref(player_id: int) -> void:
	if PlayerManager.players.has(player_id):
		PlayerManager.players[player_id].fighting_island = self

# ============================== Callback functions ==============================

func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	if game_state == GameManager.GameState.BUYING:
		_current_heroes.clear()


















 
