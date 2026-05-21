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

var _heroes: Array[Entity]

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

@export_group("Arena Zones")
@export var _team_zones: Dictionary[int, Area3D] = {}
@export var _center_zone: Area3D = null
@export var _full_arena_zone: Area3D = null

# ============================== Node base functions ==============================

func _ready() -> void:
	if _ready_checks() != true:
		return

# ============================== Public functions ==============================

func init_fight(left_formation: FightingFormation, right_formation: FightingFormation, left_team: int, right_team: int) -> void:
	_current_battle_id = 42
	_heroes.clear()
	_entity_manager.clear()

	if _arena_zone_manager != null:
		_arena_zone_manager.init(_team_zones, _current_battle_id, _center_zone, _full_arena_zone)

	_spawn_specs(left_formation.entity_specs, left_team)
	_spawn_specs(right_formation.entity_specs, right_team)

	_fighting_manager.fight_done.connect(_on_fighting_manager_fight_done, CONNECT_ONE_SHOT)
	fighting_manager.init(spawn_manager, _current_battle_id)


func get_fighting_heroes() -> Array[Entity]:
	return _heroes

# ============================== Private functions ==============================

func _spawn_specs(specs: Array[EntitySpec], team: int) -> void:
	var local_player: Player = PlayerManager.get_local_player()
	for spec: EntitySpec in specs:
		var ctx := EntityContext.new()
		ctx.team = team
		ctx.battle_id = _current_battle_id
		ctx.spawn_manager = _spawn_manager
		ctx.arena_zone_manager = _arena_zone_manager
		ctx.fighting_state = Entity.FightingState.IDLE
		ctx.display_mode = Entity.DisplayMode.FIGHTING_PHASE
		# En solo : local player possède toutes les unités côté joueur.
		# En multi (futur) : faudra une convention via team ou un mapping explicite.
		if spec is HeroSpec or spec is AcolyteSpec:
			ctx.runtime_owner_player = local_player
		var node: Node = spec.spawn_into(self, ctx)
		var entity := node as Entity
		if entity != null:
			entity.fight_role = _fight_role_for_spec(spec)
			if entity.is_hero():
				_heroes.append(entity)


# Map a spec type to its fight role. Handles both the new typed specs
# (HeroSpec/AntagonistSpec/AcolyteSpec) and the legacy FightingEntitySpec
# with its internal `role` enum — to be removed once all .tres are migrated.
static func _fight_role_for_spec(spec: EntitySpec) -> Entity.FightRole:
	if spec is HeroSpec or spec is AntagonistSpec:
		return Entity.FightRole.MAIN
	if spec is AcolyteSpec:
		return Entity.FightRole.SECONDARY
	if spec is FightingEntitySpec:
		var legacy: FightingEntitySpec = spec
		match legacy.role:
			FightingEntitySpec.FightingRole.ANTAGONIST, FightingEntitySpec.FightingRole.HERO:
				return Entity.FightRole.MAIN
			FightingEntitySpec.FightingRole.ACOLYTE:
				return Entity.FightRole.SECONDARY
	return Entity.FightRole.EXTRA


func _ready_checks() -> bool:
	if _fighting_manager == null:
		printerr("FightingArea: No FightingManager")
		return false

	if _entity_manager == null:
		printerr("FightingArea: No EntityManager")
		return false

	return true

# ============================== Callbacks ==============================

func _on_fighting_manager_fight_done(_unused: FightingManager, _winner_teams_order: Array[int]) -> void:
	if _current_battle_id < 0: return
	_heroes.clear()
