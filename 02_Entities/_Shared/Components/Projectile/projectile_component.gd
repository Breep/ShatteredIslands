class_name ProjectileComponent
extends EntityComponent

# Rayon (en unités monde) de spread ajouté par projectile supplémentaire.
# count=1 → rayon 0 (spawn pile au point indiqué). count=N → rayon = const × (N-1),
# avec les projectiles répartis sur un cercle horizontal (plan XZ).
const SPREAD_RADIUS_PER_EXTRA: float = 0.2

var _spawn_manager: SpawnManager

var _ability_projectiles_pool: Array[Projectile.Type]

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.projectile != null and _owner.projectile != self:
		Verbose.trace("Override: ProjectileComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.projectile.queue_free()
	_owner.projectile = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.projectile != self:
		return

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	if spawn_manager == null:
		Verbose.error("Trying to connect to a <null> SpawnManager", Verbose.Category.ENTITY_MODULE)
		return
	_spawn_manager = spawn_manager


func projectile_attack(target: Entity, projectile_type: Projectile.Type, projectile_spawn: Node3D, projectile_stats: ProjectileStats, is_auto_attack: bool = false) -> void:
	if _owner.alterations.has_timed(Alteration.Type.STUN):
		return

	if not is_auto_attack and _owner.alterations.has_timed(Alteration.Type.SILENCE):
		Verbose.debug("Projectile blocked by SILENCE on " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
		return

	if _spawn_manager == null:
		Verbose.error("No SpawnManager connected", Verbose.Category.ENTITY_MODULE)
		return
	
	var category: int = Projectile.Category.AUTO_ATTACK_PROJECTILE if is_auto_attack \
		else Projectile.Category.ABILITY_PROJECTILE
	var matching := _collect_matching_modifiers(projectile_type, category)
	_bake_modifier_callbacks(projectile_stats, matching)
	var count := _resolve_spawn_count(matching)
	projectile_stats.level = _resolve_spawn_level(matching)
	projectile_stats.bounces_remaining = _resolve_spawn_bounce(matching, projectile_stats.bounces_remaining)

	for i in count:
		var offset := _compute_spread_offset(i, count)
		_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats.duplicate(), offset)


func register_projectile(projectile_type: Projectile.Type) -> void:
	if _ability_projectiles_pool.has(projectile_type): return
	_ability_projectiles_pool.append(projectile_type)


func unregister_projectile(projectile_type: Projectile.Type) -> void:
	_ability_projectiles_pool.erase(projectile_type)


# Fire a random projectile type from the pool of projectiles of the Entity
func fire_random(target: Entity, projectile_spawn: Node3D, projectile_size: int = -1) -> void:
	Verbose.trace("Firing random ability projectile", Verbose.Category.PROJECTILE)
	if _ability_projectiles_pool.is_empty(): return

	var candidates: Array = _ability_projectiles_pool
	if projectile_size >= 0:
		candidates = _ability_projectiles_pool.filter(
			func(type: Projectile.Type) -> bool: return Shared.get_projectile_size(type) == projectile_size)
	if candidates.is_empty():
		Verbose.trace("No ability projectile matching size " + str(projectile_size), Verbose.Category.PROJECTILE)
		return

	var projectile_type: Projectile.Type = Utils.pick_random(candidates, _owner.battle_id, "fire_random")
	projectile_attack(target, projectile_type, projectile_spawn, ProjectileStats.new())


# ============================== Private functions ==============================

func _collect_matching_modifiers(p_type: int, p_category: int) -> Array[ProjectileModifier]:
	var matching: Array[ProjectileModifier] = []
	for mod: ProjectileModifier in _owner.projectile_modifiers_registry.get_all_modifiers():
		if mod.filter_meta(p_type, p_category):
			matching.append(mod)
	return matching


func _bake_modifier_callbacks(stats: ProjectileStats, modifiers: Array[ProjectileModifier]) -> void:
	for mod in modifiers:
		if mod.on_hit_callback.is_valid():
			stats.on_hit_callbacks.append(mod.on_hit_callback)
		if mod.on_spawn_callback.is_valid():
			stats.on_spawn_callbacks.append(mod.on_spawn_callback)


func _resolve_spawn_count(modifiers: Array[ProjectileModifier]) -> int:
	var callbacks: Array[Callable] = []
	for mod in modifiers:
		if mod.count_modifier_callback.is_valid():
			callbacks.append(mod.count_modifier_callback)
	return CountResolver.resolve(callbacks, 1)


func _resolve_spawn_level(modifiers: Array[ProjectileModifier]) -> int:
	var callbacks: Array[Callable] = []
	for mod in modifiers:
		if mod.level_modifier_callback.is_valid():
			callbacks.append(mod.level_modifier_callback)
	return clampi(LevelResolver.resolve(callbacks, 1), 1, Projectile.MAX_LEVEL)


# Base = bounce déjà configuré sur le projectile (lu depuis projectile_stats),
# pas une constante : les modifiers s'ajoutent par-dessus. Aucun modifier matché
# → la valeur configurée est rendue inchangée.
func _resolve_spawn_bounce(modifiers: Array[ProjectileModifier], base: float) -> float:
	var callbacks: Array[Callable] = []
	for mod in modifiers:
		if mod.bounce_modifier_callback.is_valid():
			callbacks.append(mod.bounce_modifier_callback)
	return BounceResolver.resolve(callbacks, base)


# Offset horizontal de spawn pour le i-ème projectile sur N.
# N=1 → ZERO. N>=2 → répartition uniforme sur un cercle XZ de rayon
# proportionnel à (N-1), pour que plus on tire de projectiles plus l'éventail
# s'élargit.
func _compute_spread_offset(index: int, count: int) -> Vector3:
	if count <= 1:
		return Vector3.ZERO
	var radius: float = SPREAD_RADIUS_PER_EXTRA * float(count - 1)
	var angle: float = TAU * float(index) / float(count)
	return Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
