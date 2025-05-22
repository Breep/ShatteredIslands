class_name FightingArea
extends Node3D

# ============================== Signals ==============================

signal map_clicked(position: Vector3)

# ============================== Network Export variables ==============================

@export var battle_id: int

# ============================== Private variables ==============================

var _battle: Battle # Battle of the fighting area
var _characters: Array[Character] # Array of all characters in the fight scene

# ============================== Public variables ==============================

var spawn_manager: SpawnManager

# ============================== Local nodes / Configuration ==============================

@export var _battle_type: Battle.BattleType

@export var _fighting_manager: FightingManager
@export var _entity_manager: EntityManager
@export var _ui_fighting_area: UIFightingArea


@export var _spawn_managers: Dictionary[Battle.BattleType, SpawnManager]

# ============================== Node base functions ==============================

func _ready() -> void:
	#_battle = RoundManager.battles[battle_id]
	
	if _ready_checks() != true:
		return
	
	_fighting_manager.battle_id = battle_id
	
	_register_self_in_shared()


func _exit_tree() -> void:
	_delete_self_in_shared()

# ============================== Public functions ==============================

func start_fight(characters: Array[Character], battle_type: Battle.BattleType) -> void:
	spawn_manager = _spawn_managers[battle_type]
	if spawn_manager == null:
		printerr("FightingArea: No SpawnManager for this battle type: ", battle_type)
	
	spawn_manager.spawn_characters(characters)
	
	_fighting_manager.fight_is_over.connect(_on_fighting_manager_fight_is_over, CONNECT_ONE_SHOT)
	_fighting_manager.start(characters)

# ============================== Private functions ==============================

func _register_self_in_shared() -> void:
	Shared.fighting_areas_ref[battle_id] = self
	Shared.entity_managers_ref[battle_id] = _entity_manager
	Shared.fighting_managers_ref[battle_id] = _fighting_manager


func _delete_self_in_shared() -> void:
	Shared.fighting_areas_ref.erase(battle_id)
	Shared.entity_managers_ref.erase(battle_id)
	Shared.fighting_managers_ref.erase(battle_id)


func _ready_checks() -> bool:
	if _fighting_manager == null:
		printerr("FightingArea: No FightingManager")
		return false
	
	if _entity_manager == null:
		printerr("FightingArea: No EntityManager")
		return false
	
	return true

# ============================== Callbacks ==============================

func _on_fighting_manager_fight_is_over(winner_teams_order: Array[int]) -> void:
	RoundManager.register_battle_result(battle_id, winner_teams_order)
	queue_free()
	# Calculate damage (=average of the winners damage)





















 
