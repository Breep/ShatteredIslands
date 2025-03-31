class_name FightingArea
extends Node3D

# ============================== Signals ==============================

signal map_clicked(position: Vector3)

# ============================== Constants ==============================

const MAPS = {
	Battle.BattleType.VS_1: preload("res://Scenes/FightingArea/Maps/test_map.tscn")
}

# ============================== Export variables ==============================

@export var battle_id: int

# ============================== Private variables ==============================

var _battle: Battle # Battle of the fighting area
var _characters: Array[Character] # Array of all characters in the fight scene

# ============================== Local nodes ==============================

@onready var _spawn_manager: SpawnManager = %SpawnManager
@onready var _fighting_manager: FightingManager = %FightingManager
@onready var _entity_manager: EntityManager = %EntityManager
@onready var _map: Node3D

#@onready var _ui_countdown: UICountdown = %Countdown
@onready var _camera: CameraFightingArea = %Camera3D
@onready var _ui_fighting_area: UIFightingArea = %UIFightingArea

# ============================== Node base functions ==============================

func _ready() -> void:
	if _spawn_manager == null:
		printerr("FightingArea: No SpawnManager")
		return
	
	if _fighting_manager == null:
		printerr("FightingArea: No FightingManager")
		return
	
	_battle = RoundManager.battles[battle_id]
	_camera.battle_id = battle_id
	match battle_id:
		0: _camera.camera_type = CameraManager.CameraType.FIGHTING_AREA_1
		1: _camera.camera_type = CameraManager.CameraType.FIGHTING_AREA_2
		2: _camera.camera_type = CameraManager.CameraType.FIGHTING_AREA_3
		3: _camera.camera_type = CameraManager.CameraType.FIGHTING_AREA_4
	
	_register_self_in_shared()


func _exit_tree() -> void:
	_delete_self_in_shared()

# ============================== Public functions ==============================

func start_fight() -> void:
	if multiplayer.is_server():
		_characters = _spawn_manager.spawn_characters(_battle.players)
		if _characters.is_empty():
			printerr("FightingArea: Can't start SpawnManager")
			return
		_fighting_manager.connect("state_changed", _on_fighting_manager_state_changed)
		_fighting_manager.start()
	else:
		_fighting_manager.queue_free()
	
	_net_start_fight.rpc()

@rpc("authority", "call_local")
func _net_start_fight() -> void:
	_ui_fighting_area.start(battle_id)

# ============================== Private functions ==============================

func _set_characters_state(fighting_state: FightingManager.FightingState) -> void:
	for character in _characters:
		character.fighting_state = fighting_state


func _register_self_in_shared() -> void:
	Shared.fighting_areas_ref[battle_id] = self
	Shared.spawn_managers_ref[battle_id] = _spawn_manager
	Shared.entity_managers_ref[battle_id] = _entity_manager
	_spawn_manager.battle_id = battle_id

func _delete_self_in_shared() -> void:
	Shared.fighting_areas_ref.erase(battle_id)
	Shared.spawn_managers_ref.erase(battle_id)
	Shared.entity_managers_ref.erase(battle_id)

# ============================== Callbacks ==============================

func _on_fighting_manager_state_changed(state: FightingManager.FightingState) -> void:
	print("FightingArea: _on_fighting_manager_state_changed() ", state)
	_set_characters_state(state)
	#if state == FightingManager.FightingState.STARTING:
		#_ui_countdown.start(5, "FIGHT") # TODO remonter l'info de la durée du countdown depuis le fightmanager
