class_name AutoAttackComponent
extends EntityComponent

# Mécanique d'auto-attaque complète : prend une cible standing (set_target/clear_target),
# l'approche via MovementComponent si hors-portée, l'attaque à cadence fixe selon attack_speed.
# Émet target_dropped quand la cible devient invalide — le controller décide de la suite.
# La sélection de cible est externe (AIController, PlayerController...).

# ============================== Enums ==============================

enum AttackPhase {
	COOLDOWN, # Waiting for cooldown before next attack
	APPROACHING, # Moving towards target
	ATTACKING # Attack in progress — tick counter running
}

enum ActiveAttackVar {
	TARGET,
	PROJECTILE_TYPE,
	SPAWN_NODE,
	STATS,
	DAMAGE_MODIFIER_CALLBACKS,
	ADDITIONAL_CALLBACKS,
}

# ============================== Signals ==============================

signal attack_started(lock_seconds: float) # Notify animation (visual only)
signal attack_completed() # Attack cycle complete, ready for next attack
signal target_changed(new_target: Entity) # Standing target changed (incl. set to null)
signal target_dropped(reason: String) # Target became invalid mid-loop (death, despawn...)

# ============================== Constants ==============================

const TICKS_PER_SECOND: int = 60
# Defaults used when the owner is not a Hero (or has no entity_desc).
# Hero owners override via HeroDesc.aa_anim_ratio / aa_release_normalized.
const DEFAULT_AA_ANIM_RATIO: float = 0.8        # % of cycle occupied by anim → tick where animation ends
const DEFAULT_AA_RELEASE_NORMALIZED: float = 0.5 # position of hit within anim (0..1)

# ============================== Export variables ==============================

@export var _projectile_spawn: Node3D

# ============================== Private variables ==============================

var _current_phase: AttackPhase = AttackPhase.COOLDOWN

# Module references (set via connect_modules)
var movement: MovementComponent = null
var _animation_module = null # AnimationComponent, but no typing to avoid circular dependency

# Approach management
var _is_approaching: bool = false
var _approach_target: Entity = null

# Tick-based attack timing (deterministic)
var _ticks_since_attack_start: int = 0
var _impact_tick: int = 0
var _lock_ticks: int = 0
var _impact_applied: bool = false

# Active attack data (replaces _pending_attacks / _pending_melee_attacks)
var _active_attack_data: Dictionary = {}

var _projectile_type: Projectile.Type = Projectile.Type.SHADOW_BOLT

# Standing target + cooldown loop (fusionné depuis l'ex-AutoAttackPeriodicComponent)
var _current_target: Entity = null
var _attack_interval_ticks: int = TICKS_PER_SECOND # base cooldown in ticks
var _ticks_remaining: int = 0 # countdown to next attack
var _is_stunned: bool = false # loop paused while stunned
var _is_paused: bool = false # loop suspended by an external channel (e.g. flight)

# ============================== Node base functions ==============================

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.auto_attack != null and _owner.auto_attack != self:
		Verbose.trace("Override: AutoAttackComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.auto_attack.queue_free()
	_owner.auto_attack = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.auto_attack != self:
		return

	# Wire up signals indépendants des autres composants. Les wirings qui
	# dépendent de movement/animation sont dans connect_modules().
	_owner.stats.attack_speed_changed.connect(_on_owner_attack_speed_changed)
	_owner.died.connect(_on_owner_died)
	_recalculate_interval()


# ============================== Public functions ==============================

func connect_modules(movement_module: MovementComponent, animation_module: AnimationComponent) -> void:
	movement = movement_module
	_animation_module = animation_module

	if _owner.alterations != null:
		_owner.alterations.stunned_changed.connect(_on_owner_stunned_changed)


func set_auto_attack_spawn(projectile_spawn: Marker3D) -> void:
	_projectile_spawn = projectile_spawn


func set_projectile_type(projectile_type: Projectile.Type) -> void:
	_projectile_type = projectile_type


## Définit la cible standing. La boucle s'occupe d'approcher + attaquer à cadence.
## Passer null pour clear (équivalent à clear_target()).
func set_target(target: Entity) -> void:
	if target == _current_target: return
	_current_target = target
	# Couper toute trajectoire en cours : approche AA précédente OU déplacement
	# manuel issu du PlayerController. Si la nouvelle cible est hors-portée, l'AA
	# relancera une approche au prochain tick via _check_range_and_approach().
	# Si elle est à portée, l'entité reste statique pendant l'attaque.
	if _is_approaching:
		stop_approaching()
	elif movement != null:
		movement.stop_following()
	target_changed.emit(target)


func clear_target() -> void:
	set_target(null)


func get_current_target() -> Entity:
	return _current_target


## Called every tick by Entity.process_tick() (deterministic, fixed 1/60s step).
## Drives both the in-flight attack counters and the periodic cooldown loop.
## Suspend/resume the auto-attack loop from an external channel that takes control
## of the entity (e.g. the Skeleton Dragon's "Vol fracassant" flight, future channels…).
## Pausing DROPS any in-progress swing through the shared _cancel_attack() (like the
## stun path) — so no delayed impact lands while suspended. Resuming PRIMES an
## immediate attack (_ticks_remaining = 0): the channels using this want to re-engage
## at once (e.g. aerial enrage starting), unlike a stun which re-arms a full cooldown.
func set_paused(paused: bool) -> void:
	_is_paused = paused
	if paused:
		_cancel_attack()
	else:
		_ticks_remaining = 0


func process_tick() -> void:
	# Boucle de décision/exécution d'auto-attaque = simulation : serveur uniquement.
	# Côté client, les auto-attaques sont rejouées par le BattleReader (pas simulées localement).
	if not multiplayer.is_server(): return
	if _is_paused: return # suspended by an external channel (see set_paused), like a stun
	if _is_stunned: return
	if not _owner.is_alive(): return

	# Phase 1 : avancer le cycle d'attaque en cours (impact + lock_ticks)
	if _current_phase == AttackPhase.ATTACKING:
		_advance_active_attack()
		return # On ne countdown pas pendant qu'on attaque

	# Phase 2 : boucle périodique. Sans cible standing → idle.
	if _current_target == null: return

	# Valider la cible
	if not _is_target_valid(_current_target):
		_drop_target("target invalid")
		return

	# En approche : check arrivée
	if _is_approaching:
		if _owner.is_target_in_attack_range(_current_target):
			stop_approaching()
			_trigger_attack(_current_target)
		return

	# COOLDOWN : décompte vers la prochaine attaque
	_ticks_remaining -= 1
	if _ticks_remaining <= 0:
		_trigger_attack(_current_target)


func is_attacking() -> bool:
	return _current_phase == AttackPhase.ATTACKING


func is_approaching() -> bool:
	return _is_approaching


func get_approach_target() -> Entity:
	return _approach_target


func stop_approaching() -> void:
	if _is_approaching and movement != null:
		movement.stop_following()
	_is_approaching = false
	_approach_target = null
	_current_phase = AttackPhase.COOLDOWN


## Replay client d'un swing d'auto-attaque (log AUTO_ATTACK rejoué par le BattleReader).
## VISUEL PUR : oriente vers la cible et déclenche l'anim/son via attack_started — aucun
## dégât, aucun projectile, aucune décision. Les dégâts arrivent par le log action_received.
func execute_auto_attack(target: Entity) -> void:
	if not is_instance_valid(target): return
	if _owner != null:
		_owner.look_at_target_y_only(target.global_position)
	_calculate_attack_timings(_attack_interval_ticks)
	attack_started.emit(float(_lock_ticks) / float(TICKS_PER_SECOND))


# ============================== Private functions ==============================

func _advance_active_attack() -> void:
	_ticks_since_attack_start += 1

	# Impact tick — apply damage / spawn projectile
	if not _impact_applied and _ticks_since_attack_start >= _impact_tick:
		_impact_applied = true
		_execute_attack_impact()

	# Lock tick — attack phase complete
	if _ticks_since_attack_start >= _lock_ticks:
		_current_phase = AttackPhase.COOLDOWN
		_active_attack_data.clear()
		# attack_speed est la seule source de vérité : le cycle total (anim + idle)
		# doit durer _attack_interval_ticks. L'anim en a déjà consommé _lock_ticks.
		_ticks_remaining = maxi(0, _attack_interval_ticks - _lock_ticks)
		_owner.auto_attack_completed.emit(_owner)
		attack_completed.emit()


func _trigger_attack(target: Entity) -> bool:
	if not _check_range_and_approach(target):
		return false # Out of range, approach started or failed

	if _owner != null:
		_owner.look_at_target_y_only(target.global_position)

	# Swing engagé : on le logge (serveur) pour que le client le rejoue (execute_auto_attack).
	_owner.auto_attack_launched.emit(target)

	_current_phase = AttackPhase.ATTACKING

	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED: _start_ranged_attack(target)
		EntityStats.AutoAttackType.MELEE: _start_melee_attack(target)

	return true


func _is_target_valid(target: Entity) -> bool:
	if not is_instance_valid(target): return false
	if target.is_queued_for_deletion(): return false
	if target.is_dead(): return false
	if target.alterations.has_state(Alteration.Type.UNTARGETABLE) : return false
	return true


func _drop_target(reason: String) -> void:
	_current_target = null
	if _is_approaching:
		stop_approaching()
	target_changed.emit(null)
	target_dropped.emit(reason)


func _cancel_attack() -> void:
	stop_approaching()
	_active_attack_data.clear()
	_ticks_since_attack_start = 0
	_impact_applied = false
	_current_phase = AttackPhase.COOLDOWN

	if _animation_module != null:
		_animation_module.stop_attack_animation()

	attack_completed.emit()


func _calculate_attack_timings(interval_ticks: int) -> void:
	var anim_ratio: float = _resolve_aa_anim_ratio()
	var release_normalized: float = _resolve_aa_release_normalized()
	# Impact happens at release_normalized within the animation, which itself
	# spans anim_ratio of the cycle → impact lands at (anim_ratio * release) of the cycle.
	var impact_ratio: float = anim_ratio * release_normalized
	_impact_tick = maxi(1, int(interval_ticks * impact_ratio))
	_lock_ticks = maxi(_impact_tick + 1, int(interval_ticks * anim_ratio))


func _resolve_aa_anim_ratio() -> float:
	#if _owner.entity_desc != null:
		#return _owner.entity_desc.aa_anim_ratio # TODO c'est lui qui décide quel aa anim à juoer
	return 0.7


func _resolve_aa_release_normalized() -> float:
	#if _owner.entity_desc != null:
		#return _owner.entity_desc.aa_release_normalized
	return DEFAULT_AA_RELEASE_NORMALIZED


func _start_attack_tick_counter(interval_ticks: int) -> void:
	_ticks_since_attack_start = 0
	_impact_applied = false
	_calculate_attack_timings(interval_ticks)

	# Calculate lock duration in seconds for animation sync
	var lock_seconds: float = float(_lock_ticks) / float(TICKS_PER_SECOND)
	attack_started.emit(lock_seconds)


func _check_range_and_approach(target: Entity) -> bool:
	# Portée (corps-à-corps pour le mélée) centralisée sur Entity.
	if _owner.is_target_in_attack_range(target):
		return true

	# Out of range - try to approach
	if movement != null:
		_is_approaching = true
		_approach_target = target
		_current_phase = AttackPhase.APPROACHING
		movement.follow_entity(target)
		Verbose.debug("AutoAttackModule: Starting approach to target", Verbose.Category.ENTITY_MODULE)
		return false

	# No movement module (fixed turret) - fail attack
	Verbose.debug("AutoAttackModule: Target out of range, no movement module", Verbose.Category.ENTITY_MODULE)
	return false


func _start_ranged_attack(target: Entity) -> void:
	var projectile_spawn: Node3D = _projectile_spawn if _projectile_spawn != null else _owner
	var projectile_stats: ProjectileStats = _prepare_projectile_stats()

	var attack_cmd = AttackCommand.new().setup(
		target,
		_projectile_type,
		projectile_spawn,
		projectile_stats
	)

	if attack_cmd == null:
		Verbose.error("Can't create AttackCommand for ranged attack", Verbose.Category.ENTITY_MODULE)
		_current_phase = AttackPhase.COOLDOWN
		_ticks_remaining = _attack_interval_ticks
		attack_completed.emit()
		return

	# Store active attack data
	_active_attack_data = {
		ActiveAttackVar.TARGET: attack_cmd.target,
		ActiveAttackVar.PROJECTILE_TYPE: attack_cmd.projectile_type,
		ActiveAttackVar.SPAWN_NODE: attack_cmd.spawn_node,
		ActiveAttackVar.STATS: attack_cmd.stats,
	}

	_start_attack_tick_counter(_attack_interval_ticks)


func _start_melee_attack(target: Entity) -> void:
	var attack_stats: ProjectileStats = _prepare_projectile_stats()

	# Store active attack data
	_active_attack_data = {
		ActiveAttackVar.TARGET: target,
		ActiveAttackVar.STATS: attack_stats,
	}

	_start_attack_tick_counter(_attack_interval_ticks)


func _execute_attack_impact() -> void:
	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED:
			_execute_ranged_impact()
		EntityStats.AutoAttackType.MELEE:
			_execute_melee_impact()


func _execute_ranged_impact() -> void:
	if _active_attack_data.is_empty():
		return

	var target_ref = _active_attack_data.get(ActiveAttackVar.TARGET)
	if not is_instance_valid(target_ref) or target_ref.is_queued_for_deletion():
		return

	var target: Entity = target_ref
	var projectile_type: Projectile.Type = _active_attack_data.get(ActiveAttackVar.PROJECTILE_TYPE)
	var spawn_node: Node3D = _active_attack_data.get(ActiveAttackVar.SPAWN_NODE)
	var stats: ProjectileStats = _active_attack_data.get(ActiveAttackVar.STATS)

	_owner.projectile.projectile_attack(
		target,
		projectile_type,
		spawn_node,
		stats,
		true
	)


func _execute_melee_impact() -> void:
	if _active_attack_data.is_empty():
		return

	var target_ref = _active_attack_data.get(ActiveAttackVar.TARGET)
	if not is_instance_valid(target_ref) or target_ref.is_queued_for_deletion():
		return

	var target: Entity = target_ref
	var stats: ProjectileStats = _active_attack_data.get(ActiveAttackVar.STATS)

	# Execute all on-hit callbacks
	for cb: Callable in stats.on_hit_callbacks:
		if cb.is_valid():
			cb.call({
				ProjectileStats.VarType.SOURCE: _owner,
				ProjectileStats.VarType.TARGET: target,
				ProjectileStats.VarType.PROJECTILE: null,
				ProjectileStats.VarType.POSITION: _owner.global_position
			})


func _recalculate_interval() -> void:
	var attack_speed: float = _owner.stats.attack_speed
	if attack_speed <= 0:
		Verbose.error("Attack speed is <= 0 on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_attack_interval_ticks = TICKS_PER_SECOND
	else:
		_attack_interval_ticks = maxi(1, int(TICKS_PER_SECOND / attack_speed))


func _prepare_projectile_stats() -> ProjectileStats:
	var projectile_stats := ProjectileStats.new()

	# Create damage callback
	var damage_modifiers_callbacks: Array[Callable]
	var additional_callbacks: Array[Callable]
	_consume_modifiers(damage_modifiers_callbacks, additional_callbacks)
	projectile_stats.on_hit_callbacks.append(func(data: Dictionary):
		var hit_target = data[ProjectileStats.VarType.TARGET]
		var hit_source = data[ProjectileStats.VarType.SOURCE]

		var mod = {
			AutoAttackModifier.VarType.SOURCE: hit_source,
			AutoAttackModifier.VarType.TARGET: hit_target,
			AutoAttackModifier.VarType.DAMAGE_ADD: 0,
			AutoAttackModifier.VarType.DAMAGE_MUL: 100,
		}
		for damage_modifiers_callback in damage_modifiers_callbacks:
			damage_modifiers_callback.call(mod)

		var add: float = mod[AutoAttackModifier.VarType.DAMAGE_ADD]
		var mul: float = mod[AutoAttackModifier.VarType.DAMAGE_MUL]
		var damage: float = (_owner.stats.attack_damage + add) * (mul / 100.0)
		var damage_done: float = 0
		if hit_source and hit_target:
			damage_done = hit_source.damage.direct(hit_target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"auto_attack")

		for additional_callback in additional_callbacks:
			additional_callback.call({
				AutoAttackModifier.VarType.SOURCE: hit_source,
				AutoAttackModifier.VarType.TARGET: hit_target,
				AutoAttackModifier.VarType.POSITION: data[ProjectileStats.VarType.POSITION],
				AutoAttackModifier.VarType.DAMAGE: damage_done,
				AutoAttackModifier.VarType.PROJECTILE: data[ProjectileStats.VarType.PROJECTILE],
			})
	)

	return projectile_stats


# Résout un impact d'auto-attaque COMPLET sur une cible donnée, instantané :
# damage_modifiers (Executioner, RussianRoulette…) + dégâts + effets additionnels
# (poison, ignite, shield…). Utilisé pour les frappes secondaires type cleave.
# Le projectile transmis aux callbacks est null (une frappe cleave ne rebondit pas).
# Note : ré-exécute les modifiers persistants ; protéger l'appelant contre la
# ré-entrance (un effet de cleave ne doit pas se re-cleaver lui-même).
func resolve_strike(hit_source: Entity, hit_target: Entity) -> float:
	if not is_instance_valid(hit_source) or not is_instance_valid(hit_target):
		return 0.0
	var damage_modifiers_callbacks: Array[Callable] = []
	var additional_callbacks: Array[Callable] = []
	_consume_modifiers(damage_modifiers_callbacks, additional_callbacks)

	var mod := {
		AutoAttackModifier.VarType.SOURCE: hit_source,
		AutoAttackModifier.VarType.TARGET: hit_target,
		AutoAttackModifier.VarType.DAMAGE_ADD: 0,
		AutoAttackModifier.VarType.DAMAGE_MUL: 100,
	}
	for damage_modifiers_callback in damage_modifiers_callbacks:
		damage_modifiers_callback.call(mod)

	var add: float = mod[AutoAttackModifier.VarType.DAMAGE_ADD]
	var mul: float = mod[AutoAttackModifier.VarType.DAMAGE_MUL]
	var damage: float = (_owner.stats.attack_damage + add) * (mul / 100.0)
	var damage_done: float = hit_source.damage.direct(hit_target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"auto_attack")

	for additional_callback in additional_callbacks:
		additional_callback.call({
			AutoAttackModifier.VarType.SOURCE: hit_source,
			AutoAttackModifier.VarType.TARGET: hit_target,
			AutoAttackModifier.VarType.POSITION: hit_target.global_position,
			AutoAttackModifier.VarType.DAMAGE: damage_done,
			AutoAttackModifier.VarType.PROJECTILE: null,
		})
	return damage_done


# Applique UNIQUEMENT les effets on-hit additionnels de l'auto-attaque (riders posés
# via AutoAttackModifier.additional_effect_callback : poison/lifesteal/... de cartes)
# sur une cible, SANS infliger les dégâts d'auto-attaque ni lire l'AD. Utilisé par les
# capacités qui "appliquent les effets on-hit de l'AA" (ex: ultimate Flèche du Prédateur).
# damage_done = dégâts déjà infligés par la capacité, transmis aux riders qui scalent dessus.
# Note : ré-exécute les modifiers persistants ; protéger l'appelant contre la ré-entrance.
func apply_on_hit_effects(hit_source: Entity, hit_target: Entity, damage_done: float) -> void:
	if not is_instance_valid(hit_source) or not is_instance_valid(hit_target):
		return
	var damage_modifiers_callbacks: Array[Callable] = []
	var additional_callbacks: Array[Callable] = []
	_consume_modifiers(damage_modifiers_callbacks, additional_callbacks)

	for additional_callback in additional_callbacks:
		additional_callback.call({
			AutoAttackModifier.VarType.SOURCE: hit_source,
			AutoAttackModifier.VarType.TARGET: hit_target,
			AutoAttackModifier.VarType.POSITION: hit_target.global_position,
			AutoAttackModifier.VarType.DAMAGE: damage_done,
			AutoAttackModifier.VarType.PROJECTILE: null,
		})


func _consume_modifiers(damage_modifier_callbacks: Array[Callable], additional_callbacks: Array[Callable]) -> void:
	for aa_modifier: AutoAttackModifier in _owner.auto_attack_modifier_registry.consume_all_modifiers():
		if aa_modifier.additional_effect_callback.is_valid():
			additional_callbacks.append(aa_modifier.additional_effect_callback)
		if aa_modifier.damage_modifier_callback.is_valid():
			damage_modifier_callbacks.append(aa_modifier.damage_modifier_callback)


# ============================== Callbacks ==============================

func _on_owner_stunned_changed(is_active: bool, _duration: float, _infinite: bool) -> void:
	_is_stunned = is_active
	if is_active:
		_cancel_attack()
	else:
		_ticks_remaining = _attack_interval_ticks


func _on_owner_attack_speed_changed(_new_attack_speed: float) -> void:
	_recalculate_interval()


func _on_owner_died() -> void:
	_drop_target("owner died")
	_cancel_attack()
