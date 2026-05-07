class_name FightingArea
extends Node3D

# ============================== Signals ==============================

@warning_ignore("unused_signal")
signal action_received(entity_ref: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
@warning_ignore("unused_signal")
signal action_done(source: Entity, target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
@warning_ignore("unused_signal")
signal projectile_spawned(source: Entity, target: Entity, projectile_type: Projectile.Type, projectile: Projectile, gpos: Vector3)
@warning_ignore("unused_signal")
signal spell_casted(source: Entity, target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary)
@warning_ignore("unused_signal")
signal entity_died(victim: Entity)
@warning_ignore("unused_signal")
signal entity_spawned(entity: Entity, entity_type: Entity.EntityType, gpos: Vector3)
@warning_ignore("unused_signal")
signal projectile_target_hit(target: Entity, gpos: Vector3, projectile_uid: int)

# ============================== Network Export variables ==============================

@export var _current_battle_id: int = -1

# ============================== Private variables ==============================

var _heroes: Array[Hero]
var _battle_type: Battle.BattleType

# ============================== Public variables ==============================

# ============================== Local nodes / Configuration ==============================

@export var _spawn_manager: SpawnManager
var spawn_manager: SpawnManager:
	get: return _spawn_manager

@export var _fighting_manager: FightingManager
var fighting_manager: FightingManager:
	get: return _fighting_manager

@export var _entity_manager: EntityManager
var entity_manager: EntityManager:
	get: return _entity_manager

@export var _fighting_event_registry: FightingEventRegistry
var fighting_event_registry: FightingEventRegistry:
	get: return _fighting_event_registry

@export var _arena_zone_manager: ArenaZoneManager
var arena_zone_manager: ArenaZoneManager:
	get: return _arena_zone_manager

@export var _fighting_floors: Dictionary[Battle.BattleType, FightingFloor]

# ============================== Node base functions ==============================

func _ready() -> void:
	if _ready_checks() != true:
		return

# ============================== Public functions ==============================

# Spawn all heroes on the FightingArea according to the battle
# Connect all heroes to this FightingArea
func init_fight(heroes: Array[Hero], battle_type: Battle.BattleType, battle_id: int = -1) -> void:
	Verbose.debug("Initiating a fight | " + str(Battle.BattleType.keys()[battle_type]) + " | " + str(heroes.size()) + " | " + str(battle_id), Verbose.Category.FIGHTING_AREA)
	_current_battle_id = battle_id
	_heroes = heroes
	_battle_type = battle_type
	
	var hero_spawner: HeroSpawner = _set_fighting_floor(battle_type).init(spawn_manager, battle_id)
	if hero_spawner == null:
		Verbose.error("FightingArea: No HeroSpawner for this battle type: " + str(Battle.BattleType.keys()[battle_type]), Verbose.Category.FIGHTING_AREA)
		return
	
	_fighting_manager.fight_is_over.connect(_on_fighting_manager_fight_is_over, CONNECT_ONE_SHOT)
	fighting_manager.init(spawn_manager, battle_id, heroes)
	
	_entity_manager.clear()
	hero_spawner.spawn_heroes(heroes)


func init_fight_2(player_encounter: FightingEncounter, mob_encounter: FightingEncounter) -> void:
	Verbose.debug("Initiating a fight Player VS Mob [" + mob_encounter.encounter_id + "]", Verbose.Category.FIGHTING_AREA)
	for entity_spec: EntitySpec in mob_encounter.entity_specs:
		var entity: Entity = entity_spec.entity_scene.instantiate()
		entity.custom_base_stats = entity_spec.stats_override
		_spawn_manager.spawn_entity(entity, entity_spec.free_position)


func get_fighting_heroes() -> Array[Hero]:
	return _heroes

func get_battle_type() -> Battle.BattleType:
	return _battle_type

# ============================== Private functions ==============================

func _ready_checks() -> bool:
	if _fighting_manager == null:
		printerr("FightingArea: No FightingManager")
		return false
	
	if _entity_manager == null:
		printerr("FightingArea: No EntityManager")
		return false
	
	return true


func _set_fighting_floor(battle_type: Battle.BattleType) -> HeroSpawner:
	for fighting_floor in _fighting_floors.values():
		fighting_floor.set_inactive()
	var fighting_floor := _fighting_floors[battle_type]
	var hero_spawner := fighting_floor.set_active()
	
	# Initialize arena zone manager with zones from fighting floor
	if _arena_zone_manager != null:
		_arena_zone_manager.init(
			fighting_floor.team_zones,
			_current_battle_id,
			fighting_floor.center_zone,
			fighting_floor.full_arena_zone
		)
	
	return hero_spawner

# ============================== Callbacks ==============================

func _on_fighting_manager_fight_is_over(_unused: FightingManager, winner_teams_order: Array[int]) -> void:
	if _current_battle_id < 0: return
	_heroes.clear()
	RoundManager.register_battle_result(_current_battle_id, winner_teams_order)
