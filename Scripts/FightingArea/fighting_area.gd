class_name FightingArea
extends Node3D

# ============================== Signals ==============================

signal map_clicked(position: Vector3)

# ============================== Constants ==============================

const MAPS = {
	Battle.BattleType.VS_1: preload("res://Scenes/FightingArea/Maps/test_map.tscn")
}

# ============================== Private variables ==============================

var _battle: Battle # Battle of the fighting area
var _characters: Array[Character] # Array of all characters in the fight scene

# ============================== Local nodes ==============================

@onready var _spawn_manager: SpawnManager = %SpawnManager
@onready var _fighting_manager: FightingManager = %FightingManager
@onready var _map: Node3D

@onready var _ui_countdown: UICountdown = %Countdown
@onready var _camera: Camera3D = %Camera3D

# ============================== Node base functions ==============================

func _ready() -> void:
	if _spawn_manager == null:
		printerr("FightingArea: No SpawnManager")
		return
	
	if _fighting_manager == null:
		printerr("FightingArea: No FightingManager")
		return
	
	# TODO remove map

# ============================== Public functions ==============================

func init(battle: Battle) -> void:
	# TODO Load map according to battle
	_battle = battle
	match battle.id:
		0: _camera.camera_type = CameraManager.CameraType.FIGHTING_AREA_1
		1: _camera.camera_type = CameraManager.CameraType.FIGHTING_AREA_2
		2: _camera.camera_type = CameraManager.CameraType.FIGHTING_AREA_3
		3: _camera.camera_type = CameraManager.CameraType.FIGHTING_AREA_4


func start_fight() -> void:
	if not _spawn_manager.spawn_characters(_battle.players):
		printerr("FightingArea: Can't start SpawnManager")
		return
	
	_characters = _get_characters()
	if _characters.is_empty():
		printerr("FightingArea: There is no character on scene, there is probably something wrong with the SpawnManager")
		return
	
	_fighting_manager.connect("state_changed", _on_fighting_manager_state_changed)
	_fighting_manager.start()
	print("Start fight")

# ============================== Private functions ==============================

# Get all characters present on scene
func _get_characters() -> Array[Character]:
	var ret: Array[Character]
	for node in get_tree().get_nodes_in_group("CHARACTER"):
		ret.append(node as Character)
	return ret


func _set_characters_state(state: FightingManager.FightingState) -> void:
	for character in _characters:
		character.set_state(state)


func _on_fighting_manager_state_changed(state: FightingManager.FightingState) -> void:
	_set_characters_state(state)
	if state == FightingManager.FightingState.STARTING:
		_ui_countdown.start(5, "FIGHT") # TODO remonter l'info de la durée du countdown depuis le fightmanager
