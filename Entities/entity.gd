class_name Entity
extends CharacterBody3D

# == VIRTUAL CLASS ==

#region ============================== Signals ==============================
signal died(self_ref: Entity)
func signal_death() -> void:
	_is_dead = true
	died.emit(self)

signal interaction_received(entity_ref: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
func signal_interaction_received(source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	interaction_received.emit(self, source, action_type, action_id, value, is_critical)
	bds_registry.register_interaction(action_id, action_type, value, is_critical)
	if source != null:
		Verbose.trace("Interaction received | '" + entity_name + "' [" + str(id) + "] | '" + source.entity_name + "' [" + str(source.id) + "] | " + \
						Utils.ActionType.keys()[action_type] + " | " + action_id + " | " + str(value) + " | " + str(is_critical), Verbose.Category.ENTITY)
	else:
		Verbose.trace("Interaction received | " + entity_name + " [" + str(id) + "] | 'Unknown source'[-1] | " + \
						Utils.ActionType.keys()[action_type] + " | " + action_id + " | " + str(value) + " | " + str(is_critical), Verbose.Category.ENTITY)

signal action_done(entity_ref: Entity, target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
func signal_action_done(target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	action_done.emit(self, target, action_type, action_id, value, is_critical)
	bds_registry.register_action(action_id, action_type, value, is_critical)
	Verbose.trace("Action done | " + entity_name + " [" + str(id) + "] | " + target.entity_name + " [" + str(target.id) + "] | " + \
					Utils.ActionType.keys()[action_type] + " | " + action_id + " | " + str(value) + " | " + str(is_critical), Verbose.Category.ENTITY)

signal action_overhealed(entity_ref: Entity, target: Entity, amount: float)
func signal_action_overhealed(target: Entity, amount: float) -> void:
	action_overhealed.emit(self, target, amount)

signal critical_action_done(entity_ref: Entity, target: Entity, action_type: Utils.ActionType, base_value: float, real_value: float)
func signal_critical_action_done(target: Entity, action_type: Utils.ActionType, base_value: float, real_value: float) -> void:
	critical_action_done.emit(self, target, action_type, base_value, real_value)

signal damage_taken(entity_ref: Entity, damage: float, damage_type: Utils.DamageType, is_critical: bool, blocked_by_armor: bool)
func signal_damage_taken(damage: float, damage_type: Utils.DamageType, is_critical: bool, blocked_by_armor: bool) -> void:
	damage_taken.emit(self, damage, damage_type, is_critical, blocked_by_armor)

signal heal_taken(entity_ref: Entity, heal_amount: float, is_critical: bool)
func signal_heal_taken(heal_amount: float, is_critical: bool) -> void:
	heal_taken.emit(self, heal_amount, is_critical)

signal spell_casted(source: Entity, target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary)
func signal_spell_casted(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary) -> void:
	spell_casted.emit(self, target, spell_type, spell_modifier)

signal stack_taken(source: Entity, stack_type: Utils.StackType, stack_number: float, is_critical: bool)
func signal_stack_taken(stack_type: Utils.StackType, stack_number: float, is_critical: bool) -> void:
	stack_taken.emit(self, stack_type, stack_number, is_critical)

signal auto_attack_started(is_critical: bool)
func signal_auto_attack_started(is_critical: bool) -> void:
	auto_attack_started.emit(is_critical)

signal auto_attack_completed()
func signal_auto_attack_completed() -> void:
	auto_attack_completed.emit()

signal spawn_completed()
func signal_spawn_completed() -> void:
	spawn_completed.emit()
#endregion

#region ============================== Enums ==============================
enum FightingState {
	SPAWNING,
	IDLE,
	FIGHTING,
	CELEBRATING,
	DEAD,
	UNDEF
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
var _is_dead: bool = false
var is_dead: bool:
	get: return _is_dead

var _is_targetable: bool = true
var is_targetable: bool:
	get: return _is_targetable

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
var _base_stats: EntityStats # Private, use base_stats property to access
var _auto_attack_module: AutoAttackModule # Optional, can be null
var _action_module: ActionModule
var _interact_module: InteractModule
var _movement_module: MovementModule # Optional, can be null

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

# Spawn settings
@export var _visual_3d: Node3D # Visual node for spawn animation
@export var spawn_duration: float = 0.5 # Duration of spawn animation in seconds
@export var skip_spawn_animation: bool = false # Skip spawn animation for instant spawn
@export var entity_name: String = "<entity name>"
#endregion

# ============================== Local Nodes ==============================

@export_group("Optional configuration")
@export var _animation_module: AnimationModule
@export var _entity_info_panel_3d: EntityInfoPanel3D
var visual: EntityInfoPanel3D:
	get: return _entity_info_panel_3d

@export var custom_base_stats: EntityStats
@export var _spawn_manager: SpawnManager
@export var _arena_zone_manager: ArenaZoneManager

@onready var bds_registry := EntityBDSRegistry.new(entity_name)

#region ============================== Fighting State ==============================
signal fighting_state_changed(new_fighting_state: FightingState)
var _fighting_state: FightingState = FightingState.UNDEF
var fighting_state: FightingState:
	get: return _fighting_state
	set(value):
		if value != _fighting_state:
			_fighting_state = value
			fighting_state_changed.emit(_fighting_state)
#endregion

#region ============================== Static variables ==============================
static var instance_count: int = 0
#endregion

#region ============================== Node base functions ==============================
func _init() -> void:
	_entity_init()


func _entity_init() -> void:
	id = instance_count
	instance_count += 1
	
	# Stats
	stats = EntityStats.new()
	_base_stats = EntityStats.new()
	
	# Default Modifier Registries
	auto_attack_modifier_registry = AutoAttackModifierRegistry.new()
	action_modifiers_registry = ActionModifiersRegistry.new()


func _enter_tree() -> void:
	_entity_enter_tree()


func _entity_enter_tree() -> void:
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
	
	_original_fighting_state = fighting_state
	_is_targetable = false  # Prevent targeting during spawn
	_is_spawning = true

func _ready() -> void:
	_entity_ready()


func _entity_ready() -> void:
	Verbose.debug("Entity [" + entity_name + "] ready", Verbose.Category.ENTITY)
	fighting_state_changed.connect(_on_entity_fighting_state_changed)
	
	if _animation_module != null:
		_animation_module.attack_hit_frame.connect(_on_animation_module_attack_hit_frame)
	
	# Start spawn sequence instead of starting modules directly
	_start_spawn()


func _process(_delta: float) -> void:
	# Check if we're approaching a target and if we're now in range
	if _is_approaching_target and _approach_target != null:
		# Check if target is still valid
		if not is_instance_valid(_approach_target) or _approach_target.is_queued_for_deletion() or _approach_target.is_dead:
			# Target died/disappeared, stop approaching
			_stop_approaching()
			signal_auto_attack_completed()
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
	ctx.fighting_state = fighting_state
	return ctx


func apply_context(context: EntityContext) -> void:
	# Apply public fields (could also use context.apply_to(self) but explicit is clearer)
	team = context.team
	battle_id = context.battle_id
	fighting_state = context.fighting_state
	
	# Apply private fields
	_spawn_manager = context.spawn_manager
	_arena_zone_manager = context.arena_zone_manager
	
	# Connect action module to managers if available
	if _action_module != null:
		if context.spawn_manager != null:
			_action_module.connect_to_spawn_manager(context.spawn_manager)
		if context.arena_zone_manager != null:
			_action_module.connect_to_arena_zone_manager(context.arena_zone_manager)


func connect_to_fighting_area(_fighting_area: FightingArea) -> void:
	printerr("Entity: virtual connect_to_fighting_area() called [", get_path(), "]")
#endregion

#region ===== Actions (Default implementations - can be overridden)
func direct_damage(target: Entity, damage: float, damage_type: Utils.DamageType, action_id: StringName) -> void:
	_action_module.direct_damage(target, damage, damage_type, action_id)

func direct_damage_percent(target: Entity, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	_action_module.direct_damage_percent(target, damage_percent, damage_type, percent_modifier, action_id)

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
			# Don't emit auto_attack_completed yet, we're approaching
			return
		else:
			# No MovementModule, can't approach - complete attack immediately
			signal_auto_attack_completed()
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
		Projectile.ProjectileType.AUTO_ATTACK,
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
		auto_attack_started.emit(projectile_stats.physical_is_critical)
	else:
		_action_module.projectile_attack(
			attack_cmd.target,
			attack_cmd.projectile_type,
			attack_cmd.spawn_node,
			attack_cmd.stats
		)
		# No animation, attack completes immediately
		signal_auto_attack_completed()


func _melee_auto_attack(target: Entity) -> void:
	var attack_stats := _auto_attack_module.prepare_projectile_stats()
	var melee_cmd := MeleeAttackCommand.new(target, attack_stats)
	
	if _animation_module != null:
		if _pending_melee_attacks.is_empty():
			_pending_melee_attacks.append(melee_cmd)
		else:
			_pending_melee_attacks[0] = melee_cmd
		auto_attack_started.emit(attack_stats.physical_is_critical)
	else:
		_execute_melee_attack(melee_cmd)
		# No animation, attack completes immediately
		signal_auto_attack_completed()


func _execute_melee_attack(cmd: MeleeAttackCommand) -> void:
	if !is_instance_valid(cmd.target) or cmd.target.is_queued_for_deletion():
		return
	_action_module.direct_damage(
		cmd.target,
		cmd.stats.physical_damage_flat,
		Utils.DamageType.PHYSICAL,
		&"auto_attack"
	)

func projectile_attack(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	_action_module.projectile_attack(target, projectile_type, projectile_spawn, projectile_stats)

func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	_action_module.cast_spell(target, spell_type, spell_modifier)

func cast_ultimate() -> void:
	printerr("Entity: cast_ultimate() called but not implemented [", get_path(), "]")

func heal(target: Entity, heal_amount: float, action_id: StringName) -> void:
	_action_module.heal(target, heal_amount, action_id)

func heal_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	_action_module.heal_percent(target, percent, percent_modifier, action_id)

func inflict_condition_stacks(target: Entity, stacks_number: float, stack_type: Utils.StackType, action_id: StringName, duration: float = 5.0) -> void:
	_action_module.inflict_condition_stacks(target, stacks_number, stack_type, action_id, duration)


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
	
	signal_auto_attack_completed()

func summon_entity(entity_type: EntityType, spawn_config: SpawnLocationConfig, entity_modifier: Dictionary) -> void:
	_action_module.summon_entity(entity_type, spawn_config, entity_modifier)

func cleanse(target: Entity, value: float, action_id: StringName) -> void:
	_action_module.cleanse(target, value, action_id)

func dispell(target: Entity, value: float, action_id: StringName) -> void:
	_action_module.dispell(target, value, action_id)
#endregion

#region ===== Interaction (Default implementations - can be overridden)
func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_damage(damage, damage_type, is_critical, action_id, source)

func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> void:
	_interact_module.take_damage_percent(percent, percent_modifier, damage_type, is_critical, action_id, source)

func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	return _interact_module.take_condition_stacks(stacks_number, stack_type, is_critical, action_id, source, duration)

func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_heal(heal_amount, is_critical, action_id, source)

func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_cleanse(value, is_critical, action_id, source)

func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_dispell(value, is_critical, action_id, source)
#endregion

#region ============================== Private functions ==============================
func _stop_approaching() -> void:
	_is_approaching_target = false
	_approach_target = null
	if _movement_module != null:
		_movement_module.stop_following()


# ============================== Spawn system ==============================
func _start_spawn() -> void:
	"""Initiate spawn sequence - set state to SPAWNING and play animation."""
	fighting_state = FightingState.SPAWNING
	Verbose.debug("Entity [" + entity_name + "] starting spawn", Verbose.Category.ENTITY)
	
	if skip_spawn_animation:
		_complete_spawn()
		return
	
	# Call virtual animation function (can be overridden by children)
	_play_spawn_animation()


func _play_spawn_animation() -> void:
	"""
	Virtual function: Play spawn animation.
	Override this in child classes for custom spawn animations.
	Default: Bounce scale animation on _visual_3d.
	"""
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
	
	# Restore targetability
	_is_targetable = true
	fighting_state = _original_fighting_state
	
	# Start modules now that collision_layer is restored
	if fighting_state == FightingState.FIGHTING:
		target_module.start()
		conditions.start()
	
	# Transition to fighting state
	signal_spawn_completed()
	Verbose.debug("Entity [" + entity_name + "] spawn completed", Verbose.Category.ENTITY)


func _on_entity_fighting_state_changed(new_fighting_state: FightingState) -> void:
	Verbose.debug("Entity [" + entity_name + "] fighting state changed to [" + str(FightingState.keys()[new_fighting_state]) + "]", Verbose.Category.ENTITY)
	match new_fighting_state:
		FightingState.IDLE:
			target_module.stop()
			conditions.stop()
		FightingState.FIGHTING:
			# Only start modules if not spawning (collision_layer would be 0)
			if not _is_spawning:
				target_module.start()
				conditions.start()
		FightingState.CELEBRATING: pass
		FightingState.DEAD: pass
		FightingState.UNDEF: pass
#endregion
