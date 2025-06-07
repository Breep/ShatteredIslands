class_name FightingArea
extends Node3D

# ============================== Network Export variables ==============================

@export var _current_battle_id: int = -1

# ============================== Private variables ==============================

var _battle: Battle # Battle of the fighting area
var _characters: Array[Character] # Array of all characters in the fight scene

# ============================== Public variables ==============================

var spawn_manager: SpawnManager

# ============================== Local nodes / Configuration ==============================

@export var _battle_type: Battle.BattleType

@export var _fighting_manager: FightingManager
var fighting_manager: FightingManager:
	get: return _fighting_manager

@export var _entity_manager: EntityManager
var entity_manager: EntityManager:
	get: return _entity_manager

@export var _ui_fighting_area: UIFightingArea

@export var _fighting_floors: Dictionary[Battle.BattleType, FightingFloor]

# ============================== Node base functions ==============================

func _ready() -> void:
	if _ready_checks() != true:
		return

# ============================== Public functions ==============================

# Spawn all characters on the FightingArea according to the battle
# Connect all characters to this FightingArea
func start_fight(characters: Array[Character], battle_type: Battle.BattleType, battle_id: int = -1) -> void:
	spawn_manager = _set_fighting_floor(battle_type)
	if spawn_manager == null:
		printerr("FightingArea: No SpawnManager for this battle type: ", battle_type)
	
	spawn_manager.spawn_characters(characters)
	for character in characters:
		character.connect_to_fighting_area(self)
	
	_current_battle_id = battle_id
	_fighting_manager.fight_is_over.connect(_on_fighting_manager_fight_is_over, CONNECT_ONE_SHOT)
	_fighting_manager.start(characters)


func set_active() -> void:
	_ui_fighting_area.set_active()


func set_inactive() -> void:
	_ui_fighting_area.set_inactive()

# ============================== Private functions ==============================

func _ready_checks() -> bool:
	if _fighting_manager == null:
		printerr("FightingArea: No FightingManager")
		return false
	
	if _entity_manager == null:
		printerr("FightingArea: No EntityManager")
		return false
	
	return true


func _set_fighting_floor(battle_type: Battle.BattleType) -> SpawnManager:
	for fighting_floor in _fighting_floors.values():
		fighting_floor.set_inactive()
	return _fighting_floors[battle_type].set_active()

# ============================== Callbacks ==============================

func _on_fighting_manager_fight_is_over(_fighting_manager: FightingManager, winner_teams_order: Array[int]) -> void:
	if _current_battle_id < 0: return
	print("Fight is over for the battle[", _current_battle_id, "]")
	RoundManager.register_battle_result(_current_battle_id, winner_teams_order)
	# Calculate damage (=average of the winners damage)





















 
