class_name Entity
extends CharacterBody3D

# == VIRTUAL CLASS ==

#region ============================== Signals ==============================
signal died(self_ref: Entity)
signal interaction_received(entity_ref: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
signal action_done(entity_ref: Entity, target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
signal action_dodged(entity_ref: Entity, source: Entity, action_type: Utils.ActionType)
signal critical_action_done(entity_ref: Entity, target: Entity, action_type: Utils.ActionType, value_before_crit: float, value_after_crit: float)
signal action_overhealed(entity_ref: Entity, target: Entity, amount: float)
signal damage_taken(entity_ref: Entity, damage: float, damage_type: Utils.DamageType, is_critical: bool, blocked_by_armor: bool)
signal heal_taken(entity_ref: Entity, heal_amount: float, is_critical: bool)
signal spell_casted(entity_ref: Entity, target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary)
signal stack_taken(entity_ref: Entity, stack_type: Utils.StackType, stack_number: float, is_critical: bool)
signal auto_attack_started(entity_ref: Entity, is_critical: bool)
signal auto_attack_completed(entity_ref: Entity)
signal spawn_completed(entity_ref: Entity)
#endregion

#region ============================== Enums ==============================
enum LifeState {
	ALIVE,
	DEAD
}

enum FightingState {
	SPAWNING,
	IDLE,
	FIGHTING,
	CELEBRATING,
	UNDEF
}

enum StatusState {
	STUNNED,
	UNTARGETABLE,
	INVINCIBLE,
	FROZEN,
	SILENCED
}

enum EntityType {
	HERO,
	SNAKE_BARREL,
	SNAKE,
	FIELD_GENERATOR,
	CHICKEN
}

enum SnakeBarrelModifier {
	SNAKE_NUMBER,
	SNAKE_POISON_STACKS,
	MAX_HEALTH
}

enum FieldGeneratorModifier {
	MAX_HEALTH,
	SHIELD_AMOUNT,
	SHIELD_INTERVAL,
	INITIAL_SHIELD,
	TARGET_COUNT
}
#endregion

#region ============================== Constants ==============================

#endregion

#region ============================== Public variables ==============================
var _is_targetable: bool = true
var is_targetable: bool:
	get: return _is_targetable

var visual: EntityInfoPanel3D: # TODO Rename this
	get: return _entity_info_panel_3d

# Auto loaded extensions
var stats: EntityStats
var conditions: ConditionsModule
var target_module: TargetModule
var auto_attack_modifier_registry: AutoAttackModifierRegistry
var action_modifiers_registry: ActionModifiersRegistry
var stat_modifiers_registry: EntityStatModifiersRegistry
var base_stats: EntityStats:
	get: return _base_stats
#endregion

#region ============================== Private variables ==============================
# Auto loaded extensions
var _action_module: ActionModule
var _base_stats: EntityStats # Private, use base_stats property to access
var _interact_module: InteractModule

# Approach target for auto-attacks
var _is_approaching_target: bool = false
var _approach_target: Entity = null

# Spawn system
var _original_fighting_state: FightingState = FightingState.UNDEF
var _is_spawning: bool = false
var _spawn_tween: Tween = null
#endregion

#region ============================== Export ==============================
@export var id: int = -1 # Multiplayer ID of the entity
@export var team: int = -1 # Team number of the entity
@export var battle_id: int = -1 # The id of the battle the entity is in
@export var entity_name: String = "<entity name>"

@export_group("Optional configuration")
@export var custom_base_stats: EntityStats

@export_subgroup("Modules")
@export var _auto_attack_module: AutoAttackModule # Optional, can be null
@export var _movement_module: MovementModule # Optional, can be null

@export_subgroup("Visual")
@export var _visual_3d: Node3D # Visual node for spawn animation
@export var _entity_info_panel_3d: EntityInfoPanel3D

@export_subgroup("Visual/Animation")
@export var _animation_module: AnimationModule
@export var spawn_duration: float = 0.5 # Duration of spawn animation in seconds
@export var skip_spawn_animation: bool = false # Skip spawn animation for instant spawn

@export_subgroup("Prototyping")
@export var _spawn_manager: SpawnManager
@export var _arena_zone_manager: ArenaZoneManager
@export var auto_attack_enabled: bool = true
#endregion

@onready var bds_registry := EntityBDSRegistry.new(entity_name)

#region ============================== Life State ==============================
signal life_state_changed(new_life_state: LifeState)
var _life_state: LifeState = LifeState.ALIVE
var life_state: LifeState:
	get: return _life_state
	set(value):
		if value != _life_state:
			_life_state = value
			life_state_changed.emit(_life_state)
#endregion

#region ============================== Fighting State ==============================
signal fighting_state_changed(new_fighting_state: FightingState)
var _fighting_state: FightingState = FightingState.UNDEF
var _initial_fighting_state_from_context: FightingState = FightingState.UNDEF  # Stored during apply_context
var fighting_state: FightingState:
	get: return _fighting_state
	set(value):
		if value != _fighting_state:
			_fighting_state = value
			fighting_state_changed.emit(_fighting_state)
#endregion

#region ============================== Status States ==============================
var status_states: Array[StatusState] = []

func has_status(status: StatusState) -> bool:
	return status_states.has(status)

func add_status(status: StatusState) -> void:
	if not status_states.has(status):
		status_states.append(status)

func remove_status(status: StatusState) -> void:
	status_states.erase(status)

func is_alive() -> bool:
	return life_state == LifeState.ALIVE

func is_dead() -> bool:
	return life_state == LifeState.DEAD
#endregion

#region ============================== Static variables ==============================
static var instance_count: int = 0
#endregion

#region ============================== Node base functions ==============================
func _init() -> void:
	id = instance_count
	instance_count += 1
	
	# Stats
	stats = EntityStats.new()
	_base_stats = EntityStats.new()
	
	# Default Modifier Registries
	auto_attack_modifier_registry = AutoAttackModifierRegistry.new()
	action_modifiers_registry = ActionModifiersRegistry.new()


func _enter_tree() -> void:
	# Stats registry needs to be created after _init() because custom_base_stats is not available in _init()
	if custom_base_stats != null:
		_base_stats = custom_base_stats
		_base_stats.reset_from_self()
		Verbose.debug("Entity [" + entity_name + "] using custom_base_stats", Verbose.Category.ENTITY)
	else:
		_base_stats = EntityStats.new()
	stat_modifiers_registry = EntityStatModifiersRegistry.new(_base_stats, stats)
	
	# Add default module if not already added
	if target_module == null:
		target_module = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.TARGET].instantiate().init(self)
		add_child(target_module)

	# Initialize conditions module (includes stack handling and timers)
	if conditions == null:
		conditions = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.CONDITIONS].instantiate().init(self)
		add_child(conditions)
	
	# Add Action/Interact Modules (default for all entities)
	if _action_module == null:
		_action_module = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.ACTION].instantiate().init(self)
		add_child(_action_module)
		if _spawn_manager != null:
			_action_module.connect_to_spawn_manager(_spawn_manager)
		if _arena_zone_manager != null:
			_action_module.connect_to_arena_zone_manager(_arena_zone_manager)
	
	if _interact_module == null:
		_interact_module = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.INTERACT].instantiate().init(self)
		add_child(_interact_module)
	
	if _movement_module == null:
		_movement_module = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.MOVEMENT].instantiate().init(self)
		add_child(_movement_module)
	
	_is_targetable = false  # Prevent targeting during spawn
	_is_spawning = true

func _ready() -> void:
	Verbose.debug("Entity [" + entity_name + "] ready", Verbose.Category.ENTITY)
	fighting_state_changed.connect(_on_fighting_state_changed)
	
	if _animation_module != null:
		_animation_module.attack_hit_frame.connect(_on_animation_module_attack_hit_frame)
	
	stats.health_changed.connect(_on_stats_health_changed)
	died.connect(_on_died)
	
	# Save the target fighting_state from context (or current if no context)
	# Don't apply it yet - let spawn sequence handle state transitions
	if _initial_fighting_state_from_context != FightingState.UNDEF:
		_original_fighting_state = _initial_fighting_state_from_context
	else:
		# Entity placed manually in scene, use current fighting_state (likely UNDEF)
		# Default to IDLE if undefined
		_original_fighting_state = fighting_state if fighting_state != FightingState.UNDEF else FightingState.IDLE
	
	# Start spawn sequence - this will set SPAWNING, then restore _original_fighting_state
	_start_spawn()


func _exit_tree() -> void:
	if stats != null and stats.health_changed.is_connected(_on_stats_health_changed):
		stats.health_changed.disconnect(_on_stats_health_changed)


func _process(_delta: float) -> void:
	# Check if we're approaching a target and if we're now in range
	if _is_approaching_target and _approach_target != null:
		# Check if target is still valid
		if not is_instance_valid(_approach_target) or _approach_target.is_queued_for_deletion() or _approach_target.is_dead:
			# Target died/disappeared, stop approaching
			_stop_approaching()
			auto_attack_completed.emit(self)
			return
		
		# Check if we're now in range
		if target_module.is_in_attack_range(_approach_target):
			# We're in range! Stop movement and launch the attack
			# IMPORTANT: Save target before _stop_approaching() sets it to null
			var target_to_attack: Entity = _approach_target
			_stop_approaching()
			# Call auto_attack again, this time we'll be in range
			auto_attack(target_to_attack)
#endregion

#region ============================== Public functions ==============================
func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_position
	direction.y = 0
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)


func get_auto_attack_spawn() -> Node3D:
	return self


func get_context() -> EntityContext:
	var ctx := EntityContext.new()
	ctx.team = team
	ctx.battle_id = battle_id
	ctx.spawn_manager = _spawn_manager
	ctx.arena_zone_manager = _arena_zone_manager
	ctx.life_state = LifeState.ALIVE  # Summons always spawn alive
	ctx.fighting_state = fighting_state  # Inherit parent's state
	Verbose.debug("Entity [" + entity_name + "] creating context with fighting_state [" + str(FightingState.keys()[fighting_state]) + "]", Verbose.Category.ENTITY)
	return ctx


func apply_context(context: EntityContext) -> void:
	# Apply public fields (could also use context.apply_to(self) but explicit is clearer)
	team = context.team
	battle_id = context.battle_id
	life_state = context.life_state
	
	# Store fighting_state but DON'T apply it yet
	# We'll apply it in _ready() after connecting the fighting_state_changed signal
	_initial_fighting_state_from_context = context.fighting_state
	Verbose.debug("Entity [" + entity_name + "] received fighting_state [" + str(FightingState.keys()[context.fighting_state]) + "] from context", Verbose.Category.ENTITY)
	
	# Apply private fields
	_spawn_manager = context.spawn_manager
	_arena_zone_manager = context.arena_zone_manager
	
	# Connect action module to managers if available
	if _action_module != null:
		if context.spawn_manager != null:
			_action_module.connect_to_spawn_manager(context.spawn_manager)
		if context.arena_zone_manager != null:
			_action_module.connect_to_arena_zone_manager(context.arena_zone_manager)


func connect_to_fighting_area(fighting_area_ref: FightingArea) -> void:
	Verbose.debug("Connecting to fighting area", Verbose.Category.ENTITY)
	if fighting_area_ref == null:
		Verbose.error("Trying to connect a null fighting area to an Entity", Verbose.Category.ENTITY)
		return
	
	_action_module.connect_to_spawn_manager(fighting_area_ref.spawn_manager)
	_action_module.connect_to_arena_zone_manager(fighting_area_ref.arena_zone_manager)
#endregion

#region ===== Actions (Default implementations - can be overridden)
func direct_damage(target: Entity, damage: float, damage_type: Utils.DamageType, action_id: StringName) -> void:
	if _action_module == null: return
	var result: Dictionary = _action_module.direct_damage(target, damage, damage_type, action_id)
	if result.is_empty(): return
	
	var action_type: Utils.ActionType = Utils.damage_to_action(damage_type)
	
	if result[ActionModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, action_type, result[ActionModule.ResultKey.BASE_VALUE], result[ActionModule.ResultKey.VALUE])
	
	action_done.emit(target, action_type, action_id, result[ActionModule.ResultKey.VALUE], result[ActionModule.ResultKey.IS_CRITICAL])


func direct_damage_percent(target: Entity, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	if _action_module == null: return
	var result: Dictionary = _action_module.direct_damage_percent(target, damage_percent, damage_type, percent_modifier, action_id)
	if result.is_empty(): return
	
	var action_type: Utils.ActionType = Utils.damage_to_action(damage_type)
	
	if result[ActionModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, action_type, result[ActionModule.ResultKey.BASE_VALUE], result[ActionModule.ResultKey.VALUE])
	
	action_done.emit(target, action_type, action_id, result[ActionModule.ResultKey.VALUE], result[ActionModule.ResultKey.IS_CRITICAL])

# Auto-attack with animation synchronization (if AnimationModule present)
var _pending_attacks: Array[AttackCommand]
var _pending_melee_attacks: Array[MeleeAttackCommand]

func auto_attack(target: Entity) -> void:
	if target == null or _auto_attack_module == null:
		printerr("Can't auto attack | " + entity_name)
		return
	
	# Check range (-1 = unlimited)
	if stats.attack_range >= 0 and not target_module.is_in_attack_range(target):
		# Target is out of range, start approaching if we have a MovementModule
		if _movement_module != null:
			_is_approaching_target = true
			_approach_target = target
			_movement_module.follow_entity(target)
			return
		else:
			auto_attack_completed.emit(self)
			return
	
	# Look at target at START of attack
	look_at_target_y_only(target.global_position)
	
	# Branch based on attack type
	match stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED:
			_ranged_auto_attack(target)
		EntityStats.AutoAttackType.MELEE:
			_melee_auto_attack(target)


func _ranged_auto_attack(target: Entity) -> void:
	var projectile_spawn := get_auto_attack_spawn()
	var projectile_stats := _auto_attack_module.prepare_projectile_stats()
	
	var attack_cmd: AttackCommand = _action_module.build_projectile_attack(
		target,
		Projectile.Type.SHADOW_BOLT,
		projectile_spawn,
		projectile_stats
	)
	
	if attack_cmd == null:
		Verbose.error("Can't create an AttackCommand | " + entity_name, Verbose.Category.ENTITY)
		return
	
	if _animation_module != null:
		if _pending_attacks.is_empty():
			_pending_attacks.append(attack_cmd)
		else:
			_pending_attacks[0] = attack_cmd
		auto_attack_started.emit(false)
	else:
		_action_module.projectile_attack(
			attack_cmd.target,
			attack_cmd.projectile_type,
			attack_cmd.spawn_node,
			attack_cmd.stats
		)
		auto_attack_completed.emit(self)


func _melee_auto_attack(target: Entity) -> void:
	var attack_stats := _auto_attack_module.prepare_projectile_stats()
	var melee_cmd := MeleeAttackCommand.new(target, attack_stats)
	
	if _animation_module != null:
		if _pending_melee_attacks.is_empty():
			_pending_melee_attacks.append(melee_cmd)
		else:
			_pending_melee_attacks[0] = melee_cmd
		auto_attack_started.emit(false)
	else:
		_execute_melee_attack(melee_cmd)
		auto_attack_completed.emit(self)


func _execute_melee_attack(cmd: MeleeAttackCommand) -> void:
	if !is_instance_valid(cmd.target) or cmd.target.is_queued_for_deletion():
		return
	for cb: Callable in cmd.stats.on_hit_callbacks:
		if cb.is_valid():
			cb.call({
				AutoAttackModifier.VarType.SOURCE: self,
				AutoAttackModifier.VarType.TARGET: cmd.target,
				AutoAttackModifier.VarType.PROJECTILE: null,
				AutoAttackModifier.VarType.POSITION: global_position
			})


func projectile_attack(target: Entity, projectile_type: Projectile.Type, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	_action_module.projectile_attack(target, projectile_type, projectile_spawn, projectile_stats)


func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	if _action_module == null: return
	_action_module.cast_spell(target, spell_type, spell_modifier)
	spell_casted.emit(target, spell_type, spell_modifier)


func cast_ultimate() -> void:
	printerr("Entity: cast_ultimate() called but not implemented [", get_path(), "]")


func heal(target: Entity, heal_amount: float, action_id: StringName) -> void:
	if _action_module == null: return
	var result: Dictionary = _action_module.heal(target, heal_amount, action_id)
	if result.is_empty(): return
	
	# Check for overheal (calculated by module)
	if result.get(ActionModule.ResultKey.OVERHEAL, 0.0) > 0:
		action_overhealed.emit(target, result[ActionModule.ResultKey.OVERHEAL])
	
	if result[ActionModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, Utils.ActionType.UTILITY_HEAL, result[ActionModule.ResultKey.BASE_VALUE], result[ActionModule.ResultKey.VALUE])
	
	action_done.emit(target, Utils.ActionType.UTILITY_HEAL, action_id, result[ActionModule.ResultKey.VALUE], result[ActionModule.ResultKey.IS_CRITICAL])


func heal_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	if _action_module == null: return
	var result: Dictionary = _action_module.heal_percent(target, percent, percent_modifier, action_id)
	if result.is_empty(): return
	
	# Check for overheal
	if result.get(ActionModule.ResultKey.OVERHEAL, 0.0) > 0:
		action_overhealed.emit(target, result[ActionModule.ResultKey.OVERHEAL])
	
	if result[ActionModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, Utils.ActionType.UTILITY_HEAL, result[ActionModule.ResultKey.BASE_VALUE], result[ActionModule.ResultKey.VALUE])
	
	action_done.emit(target, Utils.ActionType.UTILITY_HEAL, action_id, result[ActionModule.ResultKey.VALUE], result[ActionModule.ResultKey.IS_CRITICAL])


func inflict_condition_stacks(target: Entity, stacks_number: float, stack_type: Utils.StackType, action_id: StringName, duration: float = 5.0) -> void:
	if _action_module == null: return
	var result: Dictionary = _action_module.inflict_condition_stacks(target, stacks_number, stack_type, action_id, duration)
	if result.is_empty(): return
	
	var action_type: Utils.ActionType = Utils.stack_to_action(stack_type)
	
	if result[ActionModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, action_type, result[ActionModule.ResultKey.BASE_VALUE], result[ActionModule.ResultKey.VALUE])
	
	action_done.emit(target, action_type, action_id, result[ActionModule.ResultKey.VALUE], result[ActionModule.ResultKey.IS_CRITICAL])


func _on_animation_module_attack_hit_frame() -> void:
	# Handle ranged attacks (projectile)
	if not _pending_attacks.is_empty():
		var attack_cmd: AttackCommand = _pending_attacks.pop_front()
		if !is_instance_valid(attack_cmd.target) or attack_cmd.target.is_queued_for_deletion():
			return
		_action_module.projectile_attack(
			attack_cmd.target,
			attack_cmd.projectile_type,
			attack_cmd.spawn_node,
			attack_cmd.stats
		)
	
	# Handle melee attacks (direct damage)
	if not _pending_melee_attacks.is_empty():
		var melee_cmd: MeleeAttackCommand = _pending_melee_attacks.pop_front()
		_execute_melee_attack(melee_cmd)
	
	auto_attack_completed.emit(self)


func summon_entity(entity_type: EntityType, spawn_config: SpawnLocationConfig, entity_modifier: Dictionary) -> void:
	_action_module.summon_entity(entity_type, spawn_config, entity_modifier)


func cleanse(target: Entity, value: float, action_id: StringName) -> void:
	if _action_module == null: return
	var result: Dictionary = _action_module.cleanse(target, value, action_id)
	if result.is_empty(): return
	
	if result[ActionModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, result[ActionModule.ResultKey.BASE_VALUE], result[ActionModule.ResultKey.VALUE])
	
	action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, action_id, result[ActionModule.ResultKey.VALUE], result[ActionModule.ResultKey.IS_CRITICAL])


func dispell(target: Entity, value: float, action_id: StringName) -> void:
	if _action_module == null: return
	var result: Dictionary = _action_module.dispell(target, value, action_id)
	if result.is_empty(): return
	
	if result[ActionModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, Utils.ActionType.UTILITY_DISPELL, result[ActionModule.ResultKey.BASE_VALUE], result[ActionModule.ResultKey.VALUE])
	
	action_done.emit(target, Utils.ActionType.UTILITY_DISPELL, action_id, result[ActionModule.ResultKey.VALUE], result[ActionModule.ResultKey.IS_CRITICAL])
#endregion

#region ===== Interaction (Default implementations - can be overridden)
func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _interact_module == null: return 0.0
	var result: Dictionary = _interact_module.take_damage(damage, damage_type, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	if result.get(InteractModule.ResultKey.DODGED, false):
		action_dodged.emit(self, source, Utils.damage_to_action(damage_type))
		return 0.0
	
	var real_damage: float = result[InteractModule.ResultKey.VALUE]
	var blocked_by_armor: bool = result.get(InteractModule.ResultKey.BLOCKED_BY_ARMOR, false)
	
	if real_damage > 0 or (not blocked_by_armor and real_damage == 0):
		damage_taken.emit(self, real_damage, damage_type, is_critical, false)
	
	interaction_received.emit(self, source, Utils.damage_to_action(damage_type), action_id, real_damage, is_critical)
	return real_damage


func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _interact_module == null: return 0.0
	var result: Dictionary = _interact_module.take_damage_percent(percent, percent_modifier, damage_type, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	if result.get(InteractModule.ResultKey.DODGED, false):
		action_dodged.emit(self, source, Utils.damage_to_action(damage_type))
		return 0.0
	
	var real_damage: float = result[InteractModule.ResultKey.VALUE]
	var blocked_by_armor: bool = result.get(InteractModule.ResultKey.BLOCKED_BY_ARMOR, false)
	
	if real_damage > 0 or (not blocked_by_armor and real_damage == 0):
		damage_taken.emit(self, real_damage, damage_type, is_critical, false)
	
	interaction_received.emit(self, source, Utils.damage_to_action(damage_type), action_id, real_damage, is_critical)
	return real_damage


func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	if _interact_module == null: return 0.0
	var result: Dictionary = _interact_module.take_condition_stacks(stacks_number, stack_type, is_critical, action_id, source, duration)
	if result.is_empty(): return 0.0
	
	if result.get(InteractModule.ResultKey.DODGED, false):
		action_dodged.emit(self, source, Utils.stack_to_action(stack_type))
		return 0.0
	
	var stacks_applied: float = result[InteractModule.ResultKey.VALUE]
	stack_taken.emit(self, stack_type, stacks_applied, is_critical)
	interaction_received.emit(self, source, Utils.stack_to_action(stack_type), action_id, stacks_applied, is_critical)
	return stacks_applied


func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _interact_module == null: return 0.0
	var result: Dictionary = _interact_module.take_heal(heal_amount, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	if result.get(InteractModule.ResultKey.DODGED, false):
		action_dodged.emit(self, source, Utils.ActionType.UTILITY_HEAL)
		return 0.0
	
	var effective_heal: float = result[InteractModule.ResultKey.VALUE]
	if effective_heal > 0:
		heal_taken.emit(self, effective_heal, is_critical)
	
	interaction_received.emit(self, source, Utils.ActionType.UTILITY_HEAL, action_id, effective_heal, is_critical)
	return effective_heal


func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _interact_module == null: return 0.0
	var result: Dictionary = _interact_module.take_cleanse(value, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	var removed: float = result[InteractModule.ResultKey.VALUE]
	interaction_received.emit(self, source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed


func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _interact_module == null: return 0.0
	var result: Dictionary = _interact_module.take_dispell(value, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	var removed: float = result[InteractModule.ResultKey.VALUE]
	interaction_received.emit(self, source, Utils.ActionType.UTILITY_DISPELL, action_id, removed, is_critical)
	return removed
#endregion

#region ============================== Private functions ==============================
func _stop_approaching() -> void:
	_is_approaching_target = false
	_approach_target = null
	if _movement_module != null:
		_movement_module.stop_following()


#region ============================== Spawn system ==============================
func _start_spawn() -> void:
	fighting_state = FightingState.SPAWNING
	Verbose.debug("Entity [" + entity_name + "] starting spawn", Verbose.Category.ENTITY)
	
	if skip_spawn_animation:
		_complete_spawn()
		return
	
	# Call virtual animation function (can be overridden by children)
	_play_spawn_animation()


func _play_spawn_animation() -> void:
	if _visual_3d != null:
		_visual_3d.scale = Vector3.ZERO
		_spawn_tween = create_tween()
		_spawn_tween.set_ease(Tween.EASE_OUT)
		_spawn_tween.set_trans(Tween.TRANS_BACK)
		_spawn_tween.tween_property(_visual_3d, "scale", Vector3.ONE, spawn_duration)
		_spawn_tween.finished.connect(_complete_spawn)
	else:
		# No visual node, complete immediately
		Verbose.warn("Entity [" + entity_name + "] has no _visual_3d for spawn animation", Verbose.Category.ENTITY)
		_complete_spawn()


func _complete_spawn() -> void:
	Verbose.debug("Entity [" + entity_name + "] completing spawn", Verbose.Category.ENTITY)
	_is_spawning = false
	_is_targetable = true
	fighting_state = _original_fighting_state
	spawn_completed.emit(self)
	Verbose.debug("Entity [" + entity_name + "] spawn completed", Verbose.Category.ENTITY)
#endregion

func _on_fighting_state_changed(new_fighting_state: FightingState) -> void:
	Verbose.debug("Entity [" + entity_name + "] fighting state changed to [" + str(FightingState.keys()[new_fighting_state]) + "]", Verbose.Category.ENTITY)
	match new_fighting_state:
		FightingState.IDLE:
			if target_module != null: target_module.stop()
			if conditions != null: conditions.stop()
			if _auto_attack_module != null: _auto_attack_module.stop()
			if _movement_module != null: _movement_module.stop()
		FightingState.FIGHTING:
			if target_module != null: target_module.start()
			if conditions != null: conditions.start()
			if _auto_attack_module != null and auto_attack_enabled: _auto_attack_module.start()
			if _movement_module != null: _movement_module.start()
		FightingState.CELEBRATING: pass
		FightingState.UNDEF: pass


func _on_stats_health_changed(new_health: int) -> void:
	if new_health <= 0:
		died.emit(self)


func _on_died(_entity: Entity) -> void:
	Verbose.debug("Entity [" + entity_name + "] died", Verbose.Category.ENTITY)
	_stop_approaching()
	life_state = LifeState.DEAD  # Set life state
	fighting_state = FightingState.IDLE  # Stop fighting
	
	# Visual and module cleanup
	if target_module != null: target_module.stop()
	if conditions != null: conditions.stop()
	if _auto_attack_module != null: _auto_attack_module.stop()
	if _movement_module != null: _movement_module.stop()
	if _entity_info_panel_3d != null: _entity_info_panel_3d.hide()
#endregion
