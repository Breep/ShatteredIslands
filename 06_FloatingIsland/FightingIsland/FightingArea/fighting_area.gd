class_name FightingArea
extends Node3D

# Position hors-écran où sont parquées les unités joueur non encore placées.
# Elles sont spawnées normalement (mécanique SpawnManager inchangée) puis
# déplacées ici ; UIRoasterList les ramène à la souris quand le joueur les place.
const OFF_SCREEN_SPAWN_POSITION := Vector3(1000, 0, 1000)

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
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_global_fighting_phase_state_changed)

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

# TODO: Code affreux: a refacto très vite
func _spawn_specs(specs: Array[EntitySpec], team: int) -> void:
	var local_player: Player = PlayerManager.get_local_player()
	# Deux passes : héros d'abord (ils deviennent la référence runtime sur
	# ctx.runtime_owner_player.hero), puis le reste. Permet aux acolytes /
	# buildings de poser ctx.entity_owner = leur héros et fermer la chaîne
	# summoner pour SummonModifiersRegistry.
	for pass_num: int in [0, 1]:
		for spec: EntitySpec in specs:
			var spec_is_hero: bool = spec is HeroSpec
			if pass_num == 0 and not spec_is_hero: continue
			if pass_num == 1 and spec_is_hero: continue

			var ctx := EntityContext.new()
			ctx.team = team
			ctx.battle_id = _current_battle_id
			ctx.spawn_manager = _spawn_manager
			ctx.arena_zone_manager = _arena_zone_manager
			ctx.fighting_state = Entity.FightingState.IDLE
			ctx.display_mode = Entity.DisplayMode.FIGHTING_PHASE
			# Owner runtime résolu en remontant l'entry à son Roaster (Party.find_slot_of).
			# Dans le modèle unifié toute spec porte une entry ; le "spec joueur" se
			# distingue par un slot résolu (entry rattachée à un roaster). Les ennemis
			# ont une entry autonome → slot NONE. Fallback marker class + local player
			# pour compat legacy / solo.
			var party: Party = GameManager.run_context.party if GameManager.run_context != null else null
			var slot: PlayerState.Slot = PlayerState.Slot.NONE
			if spec.entry != null and party != null:
				slot = party.find_slot_of(spec.entry)
			if slot != PlayerState.Slot.NONE or spec is HeroSpec or spec is AcolyteSpec:
				var owner: Player = PlayerManager.get_player_by_slot(slot)
				ctx.runtime_owner_player = owner if owner != null else local_player
				ctx.roaster = party.get_roaster(slot) if party != null else null

			# Pose entity_owner = hero pour acolytes/buildings → leur summoner
			# pointera sur le héros, chaîne fermée pour SummonModifiersRegistry.
			# Heroes already spawned in pass 0, donc runtime_owner_player.hero
			# est posé pour ce slot.
			if not spec_is_hero and ctx.runtime_owner_player != null and ctx.runtime_owner_player.hero != null:
				var cat: Entity.Category = spec.get_entity_category()
				if cat == Entity.Category.ACOLYTE or cat == Entity.Category.BUILDING:
					ctx.entity_owner = ctx.runtime_owner_player.hero

			var node: Node = spec.spawn_into(self, ctx)
			var entity := node as Entity
			if entity != null:
				entity.fight_role = _fight_role_for_spec(spec)
				# Unité joueur non encore placée : parquée hors-écran. Le joueur la
				# ramène sur le terrain via UIRoasterList (qui marque entry.placed).
				if slot != PlayerState.Slot.NONE and spec.entry != null and not spec.entry.placed:
					entity.global_position = OFF_SCREEN_SPAWN_POSITION
				if entity.is_hero():
					_heroes.append(entity)
					# Lien runtime player -> instance de héros de cette scène.
					if ctx.runtime_owner_player != null:
						ctx.runtime_owner_player.hero = entity


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


# Étape 8 du flow run : à la fin du placement (POSITIONING → COUNTDOWN), on
# sérialise la position courante de chaque entity player sur son EntitySpec
# (ref partagée avec party.formation.entity_specs). Au prochain combat, les
# specs rejoueront ces transforms.
func _on_global_fighting_phase_state_changed(new_state: GlobalFightingManager.FightingPhaseState) -> void:
	if new_state != GlobalFightingManager.FightingPhaseState.COUNTDOWN:
		return
	if _spawn_manager == null:
		return
	var party: Party = GameManager.run_context.party if GameManager.run_context != null else null
	if party == null:
		return
	for entity: Entity in _spawn_manager.get_entities():
		if entity == null or entity.entry == null:
			continue
		var spec: EntitySpec = party.find_spec_by_entry(entity.entry)
		if spec != null:
			spec.transform = entity.transform
