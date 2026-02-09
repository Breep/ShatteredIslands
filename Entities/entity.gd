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
var _base_stats: EntityStats # Private, use base_stats property to access

var _movement_module: MovementModule # Optional, can be null
var _auto_attack_periodic_module: AutoAttackPeriodicModule # Optional, can be null

# Action Senders
var _damage_sender: ActionSenderDamageModule
var _heal_sender: ActionSenderHealModule
var _add_stack_sender: ActionSenderAddStackModule
var _remove_stack_sender: ActionSenderRemoveStackModule
var _projectile_sender: ActionSenderProjectileModule
var _spell_sender: ActionSenderSpellModule
var _summon_sender: ActionSenderSummonModule
var _auto_attack_sender: ActionSenderAutoAttackModule

# Action Receivers
var _damage_receiver: ActionReceiverDamageModule
var _heal_receiver: ActionReceiverHealModule
var _add_stack_receiver: ActionReceiverAddStackModule
var _remove_stack_receiver: ActionReceiverRemoveStackModule
var _status_receiver: ActionReceiverStatusModule
var _status_sender: ActionSenderStatusModule

# Status module
var status_module: StatusModule

# Spawn system
var _original_fighting_state: FightingState = FightingState.UNDEF
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
@export var _auto_loaded_modules: Array[Module.ModuleType] = [
	Module.ModuleType.TARGET,
	Module.ModuleType.CONDITIONS,
	Module.ModuleType.STATUS,
	Module.ModuleType.ACTION_SENDER_DAMAGE,
	Module.ModuleType.ACTION_SENDER_HEAL,
	Module.ModuleType.ACTION_SENDER_ADD_STACK,
	Module.ModuleType.ACTION_SENDER_REMOVE_STACK,
	Module.ModuleType.ACTION_SENDER_PROJECTILE,
	Module.ModuleType.ACTION_SENDER_SPELL,
	Module.ModuleType.ACTION_SENDER_SUMMON,
	Module.ModuleType.ACTION_SENDER_AUTO_ATTACK,
	Module.ModuleType.ACTION_SENDER_STATUS,
	Module.ModuleType.ACTION_RECEIVER_DAMAGE,
	Module.ModuleType.ACTION_RECEIVER_HEAL,
	Module.ModuleType.ACTION_RECEIVER_ADD_STACK,
	Module.ModuleType.ACTION_RECEIVER_REMOVE_STACK,
	Module.ModuleType.ACTION_RECEIVER_STATUS,
]

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

func has_status_state(status: StatusState) -> bool:
	return status_states.has(status)

func add_status_state(status: StatusState) -> void:
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




# ============================== Node base functions ==============================

#region ============================== Init ==============================
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
	
	# Auto-load modules from the _auto_loaded_modules list
	_auto_load_modules()
	
	_is_targetable = false  # Prevent targeting during spawn


func _ready() -> void:
	Verbose.debug("Entity [" + entity_name + "] ready", Verbose.Category.ENTITY)
	fighting_state_changed.connect(_on_fighting_state_changed)
	
	stats.health_changed.connect(_on_stats_health_changed)
	died.connect(_on_died)
	
	# TODO CHECK THIS ??
	if _initial_fighting_state_from_context != FightingState.UNDEF:
		_original_fighting_state = _initial_fighting_state_from_context
	else:
		_original_fighting_state = fighting_state if fighting_state != FightingState.UNDEF else FightingState.IDLE
	
	# Connect module interdependencies
	_connect_module_dependencies()
	
	_start_spawn()


func _exit_tree() -> void:
	if stats != null and stats.health_changed.is_connected(_on_stats_health_changed):
		stats.health_changed.disconnect(_on_stats_health_changed)
#endregion




# ============================== Public functions ==============================
#region ============================== Utils ==============================
func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_position
	direction.y = 0
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)


func get_auto_attack_spawn() -> Node3D:
	return self


func get_collision_center() -> Vector3:
	"""Returns the center of the entity's collision box for accurate projectile targeting."""
	# Search for a CollisionShape3D in the entity's children
	for child in get_children():
		if child is CollisionShape3D:
			var collision_shape: CollisionShape3D = child
			if collision_shape.shape:
				# Return the global position of the collision shape
				# This accounts for the shape's offset from the entity's pivot
				return collision_shape.global_position
	
	# Fallback to global position if no collision shape found
	return global_position
#endregion

#region ============================== Context ==============================
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
	team = context.team
	battle_id = context.battle_id
	life_state = context.life_state
	_initial_fighting_state_from_context = context.fighting_state
	_spawn_manager = context.spawn_manager
	_arena_zone_manager = context.arena_zone_manager
	
	# Connect all sender modules to managers
	var senders: Array[ActionSenderModule] = [
		_damage_sender, _heal_sender, _add_stack_sender, _remove_stack_sender,
		_projectile_sender, _spell_sender, _summon_sender, _auto_attack_sender
	]
	for module in senders:
		if module == null: continue
		if _spawn_manager != null: module.connect_to_spawn_manager(_spawn_manager)
		if _arena_zone_manager != null: module.connect_to_arena_zone_manager(_arena_zone_manager)
	
	Verbose.debug("Entity [" + entity_name + "] received fighting_state [" + str(FightingState.keys()[context.fighting_state]) + "] from context", Verbose.Category.ENTITY)


func connect_to_fighting_area(fighting_area_ref: FightingArea) -> void:
	Verbose.debug("Connecting to fighting area", Verbose.Category.ENTITY)
	if fighting_area_ref == null:
		Verbose.error("Trying to connect a null fighting area to an Entity", Verbose.Category.ENTITY)
		return
	
	# Connect all receiver modules to fighting area managers
	var receivers: Array[ActionReceiverModule] = [
		_damage_receiver, _heal_receiver, _add_stack_receiver, _remove_stack_receiver
	]
	for module in receivers:
		if module == null: continue
		module.connect_to_spawn_manager(fighting_area_ref.spawn_manager)
		module.connect_to_arena_zone_manager(fighting_area_ref.arena_zone_manager)
#endregion

#region ============================== Action Senders ==============================
func direct_damage(target: Entity, damage: float, damage_type: Utils.DamageType, action_id: StringName) -> void:
	if _damage_sender == null: return
	var result: Dictionary = _damage_sender.direct_damage(target, damage, damage_type, action_id)
	if result.is_empty(): return
	
	var action_type: Utils.ActionType = Utils.damage_to_action(damage_type)
	
	if result[ActionSenderModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, action_type, result[ActionSenderModule.ResultKey.BASE_VALUE], result[ActionSenderModule.ResultKey.VALUE])
	
	action_done.emit(target, action_type, action_id, result[ActionSenderModule.ResultKey.VALUE], result[ActionSenderModule.ResultKey.IS_CRITICAL])


func direct_damage_percent(target: Entity, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	if _damage_sender == null: return
	var result: Dictionary = _damage_sender.direct_damage_percent(target, damage_percent, damage_type, percent_modifier, action_id)
	if result.is_empty(): return
	
	var action_type: Utils.ActionType = Utils.damage_to_action(damage_type)
	
	if result[ActionSenderModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, action_type, result[ActionSenderModule.ResultKey.BASE_VALUE], result[ActionSenderModule.ResultKey.VALUE])
	
	action_done.emit(target, action_type, action_id, result[ActionSenderModule.ResultKey.VALUE], result[ActionSenderModule.ResultKey.IS_CRITICAL])


func auto_attack(target: Entity) -> void:
	if _auto_attack_sender == null: return
	_auto_attack_sender.execute_auto_attack(target)


func projectile_attack(target: Entity, projectile_type: Projectile.Type, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	if _projectile_sender == null: return
	if is_silenced():
		Verbose.debug("Entity [" + entity_name + "] projectile blocked by SILENCE", Verbose.Category.ENTITY)
		return
	_projectile_sender.projectile_attack(target, projectile_type, projectile_spawn, projectile_stats)


func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	if _spell_sender == null: return
	if is_silenced():
		Verbose.debug("Entity [" + entity_name + "] spell blocked by SILENCE", Verbose.Category.ENTITY)
		return
	_spell_sender.cast_spell(target, spell_type, spell_modifier)
	spell_casted.emit(target, spell_type, spell_modifier)


func cast_ultimate() -> void:
	printerr("Entity: cast_ultimate() called but not implemented [", get_path(), "]")


func heal(target: Entity, heal_amount: float, action_id: StringName) -> void:
	if _heal_sender == null: return
	var result: Dictionary = _heal_sender.heal(target, heal_amount, action_id)
	if result.is_empty(): return
	
	# Check for overheal (calculated by module)
	if result.get(ActionSenderModule.ResultKey.OVERHEAL, 0.0) > 0:
		action_overhealed.emit(target, result[ActionSenderModule.ResultKey.OVERHEAL])
	
	if result[ActionSenderModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, Utils.ActionType.UTILITY_HEAL, result[ActionSenderModule.ResultKey.BASE_VALUE], result[ActionSenderModule.ResultKey.VALUE])
	
	action_done.emit(target, Utils.ActionType.UTILITY_HEAL, action_id, result[ActionSenderModule.ResultKey.VALUE], result[ActionSenderModule.ResultKey.IS_CRITICAL])


func heal_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	if _heal_sender == null: return
	var result: Dictionary = _heal_sender.heal_percent(target, percent, percent_modifier, action_id)
	if result.is_empty(): return
	
	# Check for overheal
	if result.get(ActionSenderModule.ResultKey.OVERHEAL, 0.0) > 0:
		action_overhealed.emit(target, result[ActionSenderModule.ResultKey.OVERHEAL])
	
	if result[ActionSenderModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, Utils.ActionType.UTILITY_HEAL, result[ActionSenderModule.ResultKey.BASE_VALUE], result[ActionSenderModule.ResultKey.VALUE])
	
	action_done.emit(target, Utils.ActionType.UTILITY_HEAL, action_id, result[ActionSenderModule.ResultKey.VALUE], result[ActionSenderModule.ResultKey.IS_CRITICAL])


func inflict_condition_stacks(target: Entity, stacks_number: float, stack_type: Utils.StackType, action_id: StringName, duration: float = 5.0) -> void:
	if _add_stack_sender == null: return
	var result: Dictionary = _add_stack_sender.inflict_condition_stacks(target, stacks_number, stack_type, action_id, duration)
	if result.is_empty(): return
	
	var action_type: Utils.ActionType = Utils.stack_to_action(stack_type)
	
	if result[ActionSenderModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, action_type, result[ActionSenderModule.ResultKey.BASE_VALUE], result[ActionSenderModule.ResultKey.VALUE])
	
	action_done.emit(target, action_type, action_id, result[ActionSenderModule.ResultKey.VALUE], result[ActionSenderModule.ResultKey.IS_CRITICAL])


func summon_entity(entity_type: EntityType, spawn_config: SpawnLocationConfig, entity_modifier: Dictionary) -> void:
	if _summon_sender == null: return
	if is_silenced():
		Verbose.debug("Entity [" + entity_name + "] summon blocked by SILENCE", Verbose.Category.ENTITY)
		return
	_summon_sender.summon_entity(entity_type, spawn_config, entity_modifier)


func cleanse(target: Entity, value: float, action_id: StringName) -> void:
	if _remove_stack_sender == null: return
	var result: Dictionary = _remove_stack_sender.cleanse(target, value, action_id)
	if result.is_empty(): return
	
	if result[ActionSenderModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, result[ActionSenderModule.ResultKey.BASE_VALUE], result[ActionSenderModule.ResultKey.VALUE])
	
	action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, action_id, result[ActionSenderModule.ResultKey.VALUE], result[ActionSenderModule.ResultKey.IS_CRITICAL])


func dispell(target: Entity, value: float, action_id: StringName) -> void:
	if _remove_stack_sender == null: return
	var result: Dictionary = _remove_stack_sender.dispell(target, value, action_id)
	if result.is_empty(): return
	
	if result[ActionSenderModule.ResultKey.IS_CRITICAL]:
		critical_action_done.emit(target, Utils.ActionType.UTILITY_DISPELL, result[ActionSenderModule.ResultKey.BASE_VALUE], result[ActionSenderModule.ResultKey.VALUE])
	
	action_done.emit(target, Utils.ActionType.UTILITY_DISPELL, action_id, result[ActionSenderModule.ResultKey.VALUE], result[ActionSenderModule.ResultKey.IS_CRITICAL])


func inflict_status(target: Entity, status_type: Status.Type, duration: float, action_id: StringName) -> void:
	if _status_sender == null: return
	var result: Dictionary = _status_sender.inflict_status(target, status_type, duration, action_id)
	if result.is_empty(): return
	
	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	action_done.emit(target, action_type, action_id, result[ActionSenderModule.ResultKey.VALUE], false)
#endregion


#region ============================== Status Checks ==============================
func is_stunned() -> bool:
	if status_module == null: return false
	return status_module.has_status(Status.Type.STUN)


func is_silenced() -> bool:
	if status_module == null: return false
	return status_module.has_status(Status.Type.SILENCE)


func is_invulnerable() -> bool:
	if status_module == null: return false
	return status_module.has_status(Status.Type.INVULNERABLE)


func has_status(status_type: Status.Type) -> bool:
	if status_module == null: return false
	return status_module.has_status(status_type)
#endregion

#region ============================== Action Receivers ==============================
func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _damage_receiver == null: return 0.0
	if is_invulnerable():
		Verbose.debug("Entity [" + entity_name + "] damage blocked by INVULNERABLE", Verbose.Category.ENTITY)
		return 0.0
	var result: Dictionary = _damage_receiver.take_damage(damage, damage_type, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	if result.get(ActionReceiverModule.ResultKey.DODGED, false):
		action_dodged.emit(self, source, Utils.damage_to_action(damage_type))
		return 0.0
	
	var real_damage: float = result[ActionReceiverModule.ResultKey.VALUE]
	var blocked_by_armor: bool = result.get(ActionReceiverModule.ResultKey.BLOCKED_BY_ARMOR, false)
	
	if real_damage > 0 or (not blocked_by_armor and real_damage == 0):
		damage_taken.emit(self, real_damage, damage_type, is_critical, false)
	
	interaction_received.emit(self, source, Utils.damage_to_action(damage_type), action_id, real_damage, is_critical)
	return real_damage


func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _damage_receiver == null: return 0.0
	var result: Dictionary = _damage_receiver.take_damage_percent(percent, percent_modifier, damage_type, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	if result.get(ActionReceiverModule.ResultKey.DODGED, false):
		action_dodged.emit(self, source, Utils.damage_to_action(damage_type))
		return 0.0
	
	var real_damage: float = result[ActionReceiverModule.ResultKey.VALUE]
	var blocked_by_armor: bool = result.get(ActionReceiverModule.ResultKey.BLOCKED_BY_ARMOR, false)
	
	if real_damage > 0 or (not blocked_by_armor and real_damage == 0):
		damage_taken.emit(self, real_damage, damage_type, is_critical, false)
	
	interaction_received.emit(self, source, Utils.damage_to_action(damage_type), action_id, real_damage, is_critical)
	return real_damage


func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	if _add_stack_receiver == null: return 0.0
	var result: Dictionary = _add_stack_receiver.take_condition_stacks(stacks_number, stack_type, is_critical, action_id, source, duration)
	if result.is_empty(): return 0.0
	
	if result.get(ActionReceiverModule.ResultKey.DODGED, false):
		action_dodged.emit(self, source, Utils.stack_to_action(stack_type))
		return 0.0
	
	var stacks_applied: float = result[ActionReceiverModule.ResultKey.VALUE]
	stack_taken.emit(self, stack_type, stacks_applied, is_critical)
	interaction_received.emit(self, source, Utils.stack_to_action(stack_type), action_id, stacks_applied, is_critical)
	return stacks_applied


func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _heal_receiver == null: return 0.0
	var result: Dictionary = _heal_receiver.take_heal(heal_amount, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	if result.get(ActionReceiverModule.ResultKey.DODGED, false):
		action_dodged.emit(self, source, Utils.ActionType.UTILITY_HEAL)
		return 0.0
	
	var effective_heal: float = result[ActionReceiverModule.ResultKey.VALUE]
	if effective_heal > 0:
		heal_taken.emit(self, effective_heal, is_critical)
	
	interaction_received.emit(self, source, Utils.ActionType.UTILITY_HEAL, action_id, effective_heal, is_critical)
	return effective_heal


func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _remove_stack_receiver == null: return 0.0
	var result: Dictionary = _remove_stack_receiver.take_cleanse(value, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	var removed: float = result[ActionReceiverModule.ResultKey.VALUE]
	interaction_received.emit(self, source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed


func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _remove_stack_receiver == null: return 0.0
	var result: Dictionary = _remove_stack_receiver.take_dispell(value, is_critical, action_id, source)
	if result.is_empty(): return 0.0
	
	var removed: float = result[ActionReceiverModule.ResultKey.VALUE]
	interaction_received.emit(self, source, Utils.ActionType.UTILITY_DISPELL, action_id, removed, is_critical)
	return removed


func take_status(status_type: Status.Type, duration: float, action_id: StringName, source: Entity) -> float:
	if _status_receiver == null: return 0.0
	var result: Dictionary = _status_receiver.take_status(status_type, duration, action_id, source)
	if result.is_empty(): return 0.0
	
	var actual_duration: float = result[ActionReceiverModule.ResultKey.VALUE]
	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	interaction_received.emit(self, source, action_type, action_id, actual_duration, false)
	return actual_duration
#endregion




# ============================== Private functions ==============================

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
	_is_targetable = true
	fighting_state = _original_fighting_state
	spawn_completed.emit(self)
	Verbose.debug("Entity [" + entity_name + "] spawn completed", Verbose.Category.ENTITY)
#endregion

#region ============================== Auto loading ==============================
func _auto_load_modules() -> void:
	for module_type in _auto_loaded_modules:
		var module: Module = Shared.ENTITY_MODULE_SCENES[module_type].instantiate().init(self)
		match module_type:
			Module.ModuleType.TARGET: target_module = module
			Module.ModuleType.CONDITIONS: conditions = module
			Module.ModuleType.MOVEMENT: _movement_module = module
			Module.ModuleType.ACTION_SENDER_DAMAGE: _damage_sender = module
			Module.ModuleType.ACTION_SENDER_HEAL: _heal_sender = module
			Module.ModuleType.ACTION_SENDER_ADD_STACK: _add_stack_sender = module
			Module.ModuleType.ACTION_SENDER_REMOVE_STACK: _remove_stack_sender = module
			Module.ModuleType.ACTION_SENDER_PROJECTILE:
				_projectile_sender = module
				if _spawn_manager != null: _projectile_sender.connect_to_spawn_manager(_spawn_manager)
			Module.ModuleType.ACTION_SENDER_SPELL:
				_spell_sender = module
				if _spawn_manager != null: _spell_sender.connect_to_spawn_manager(_spawn_manager)
			Module.ModuleType.ACTION_SENDER_SUMMON:
				_summon_sender = module
				if _spawn_manager != null: _summon_sender.connect_to_spawn_manager(_spawn_manager)
				if _arena_zone_manager != null: _summon_sender.connect_to_arena_zone_manager(_arena_zone_manager)
			Module.ModuleType.ACTION_SENDER_AUTO_ATTACK: _auto_attack_sender = module
			Module.ModuleType.ACTION_RECEIVER_DAMAGE: _damage_receiver = module
			Module.ModuleType.ACTION_RECEIVER_HEAL: _heal_receiver = module
			Module.ModuleType.ACTION_RECEIVER_ADD_STACK: _add_stack_receiver = module
			Module.ModuleType.ACTION_RECEIVER_REMOVE_STACK: _remove_stack_receiver = module
			Module.ModuleType.ACTION_RECEIVER_STATUS: _status_receiver = module
			Module.ModuleType.ACTION_SENDER_STATUS: _status_sender = module
			Module.ModuleType.STATUS: status_module = module
			Module.ModuleType.AUTO_ATTACK_PERIODIC_MODULE: _auto_attack_periodic_module = module
		
		add_child(module)
		Verbose.debug("Entity [" + entity_name + "] auto-loaded module: " + Module.ModuleType.keys()[module_type], Verbose.Category.ENTITY)


func _connect_module_dependencies() -> void:
	if _auto_attack_sender != null:
		_auto_attack_sender.connect_modules(_movement_module, _animation_module)
	
	# Connect periodic module with auto attack sender
	if _auto_attack_periodic_module != null and _auto_attack_sender != null:
		_auto_attack_periodic_module.connect_modules(_auto_attack_sender)
	
	if _animation_module != null:
		_animation_module.connect_modules(_auto_attack_sender)
#endregion

#region ============================== Callbacks ==============================
func _on_fighting_state_changed(new_fighting_state: FightingState) -> void:
	Verbose.debug("Entity [" + entity_name + "] fighting state changed to [" + str(FightingState.keys()[new_fighting_state]) + "]", Verbose.Category.ENTITY)
	match new_fighting_state:
		FightingState.IDLE:
			if target_module != null: target_module.stop()
			if conditions != null: conditions.stop()
			if _movement_module != null: _movement_module.stop()
			if _auto_attack_periodic_module != null and auto_attack_enabled: _auto_attack_periodic_module.stop()
		FightingState.FIGHTING:
			if target_module != null: target_module.start()
			if conditions != null: conditions.start()
			if _movement_module != null: _movement_module.start()
			if _auto_attack_periodic_module != null and auto_attack_enabled: _auto_attack_periodic_module.start()
		FightingState.CELEBRATING: pass
		FightingState.UNDEF: pass


func _on_stats_health_changed(new_health: int) -> void:
	if new_health <= 0:
		died.emit(self)


func _on_died(_entity: Entity) -> void:
	Verbose.debug("Entity [" + entity_name + "] died", Verbose.Category.ENTITY)
	life_state = LifeState.DEAD  # Set life state
	fighting_state = FightingState.IDLE  # Stop fighting
	
	# Visual and module cleanup
	if target_module != null: target_module.stop()
	if conditions != null: conditions.stop()
	if _movement_module != null: _movement_module.stop()
	if _auto_attack_periodic_module != null and auto_attack_enabled: _auto_attack_periodic_module.stop()
	if _entity_info_panel_3d != null: _entity_info_panel_3d.hide()
#endregion
