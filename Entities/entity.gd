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
#endregion

#region ============================== Enums ==============================
enum FightingState {
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
	FIELD_GENERATOR
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

var stats: EntityStats

var target_module: TargetModule

var auto_attack_modifier_registry: AutoAttackModifierRegistry
var action_modifiers_registry: ActionModifiersRegistry
var stat_modifiers_registry: EntityStatModifiersRegistry
var stack_modifiers_registry: StackModifiersRegistry
#endregion

#region ============================== Private variables ==============================
var _stack_handler_module: StackHandlerModule
#endregion

#region ============================== Export ==============================
@export var id: int = -1 # Multiplayer ID of the entity
@export var team: int = -1 # Team number of the entity
@export var battle_id: int = -1 # The id of the battle the entity is in
@export var entity_name: String = "<entity name>"
#endregion

# ============================== Local Nodes ==============================

@export_group("Optional configuration")
@export var _entity_info_panel_3d: EntityInfoPanel3D
var visual: EntityInfoPanel3D:
	get: return _entity_info_panel_3d

# Custom base_stats override for quick testing (optional)
# If defined, this will be used instead of auto-generated base_stats
@export var custom_base_stats: EntityStats

var _base_stats: EntityStats # Private, use base_stats property to access
var base_stats: EntityStats:
	get: return _base_stats

@export var _spawn_manager: SpawnManager

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
	stack_modifiers_registry = StackModifiersRegistry.new()


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

	if _stack_handler_module == null:
		_stack_handler_module = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.STACK_HANDLER].instantiate().init(self)
		add_child(_stack_handler_module)


func _ready() -> void:
	_entity_ready()


func _entity_ready() -> void:
	Verbose.debug("Entity [" + entity_name + "] ready", Verbose.Category.ENTITY)
	fighting_state_changed.connect(_on_entity_fighting_state_changed)
#endregion

#region ============================== Public functions ==============================
func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_position
	direction.y = 0
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)


func get_auto_attack_spawn() -> Node3D:
	return self


func connect_to_fighting_area(_fighting_area: FightingArea) -> void:
	printerr("Entity: virtual connect_to_fighting_area() called [", get_path(), "]")
#endregion

#region ===== Actions [VIRTUAL]
func direct_attack(_target: Entity, _damage: float, _damage_type: Utils.DamageType, _action_id: StringName) -> void:
	printerr("Entity: virtual direct_attack() called [", get_path(), "]")

func direct_attack_percent(_target: Entity, _damage_percent: float, _damage_type: Utils.DamageType, _percent_modifier: Utils.PercentModifier, _action_id: StringName) -> void:
	printerr("Entity: virtual direct_attack_percent() called [", get_path(), "]")

func projectile_attack(_target: Entity, _projectile_type: Projectile.ProjectileType, _projectile_spawn: Node3D, _projectile_stats: ProjectileStats) -> void:
	printerr("Entity: virtual projectile_attack() called [", get_path(), "]")

func cast_spell(_target: Entity, _spell_type: Spell.Type, _spell_modifier: Dictionary) -> void:
	printerr("Entity: virtual cast_spell() called [", get_path(), "]")

func cast_ultimate() -> void:
	printerr("Entity: virtual cast_ultimate() called [", get_path(), "]")

func heal(_target: Entity, _heal_amount: float, _action_id: StringName) -> void:
	printerr("Entity: virtual heal() called [", get_path(), "]")

func heal_percent(_target: Entity, _percent: float, _percent_modifier: Utils.PercentModifier, _action_id: StringName) -> void:
	printerr("Entity: virtual heal_percent() called [", get_path(), "]")

func inflict_condition_stacks(_target: Entity, _stacks_number: float, _stack_type: Utils.StackType, _action_id: StringName, _duration: float = 5.0) -> void:
	printerr("Entity: virtual inflict_condition_stacks() called [", get_path(), "]")

func summon_entity(_entity_type: EntityType, _entity_spawn_global_position: Vector3, _entity_modifier: Dictionary) -> void:
	printerr("Entity: virtual summon_entity() called [", get_path(), "]")

func cleanse(_target: Entity, _value: float, _action_id: StringName) -> void:
	printerr("Entity: virtual cleanse() called [", get_path(), "]")

func dispell(_target: Entity, _value: float, _action_id: StringName) -> void:
	printerr("Entity: virtual dispell() called [", get_path(), "]")
#endregion

#region ===== Interaction [VIRTUAL]
func take_damage(_damage: float, _damage_type: Utils.DamageType, _is_critical: bool, _action_id: StringName, _source: Entity = null) -> float:
	printerr("Entity: virtual take_damage() called [", get_path(), "]")
	return -1

func take_damage_percent(_percent: float, _percent_modifier: Utils.PercentModifier, _damage_type: Utils.DamageType, _is_critical: bool, _action_id: StringName, _source: Entity = null) -> void:
	printerr("Entity: virtual take_damage_percent() called [", get_path(), "]")

func take_condition_stacks(_stacks_number: float, _stack_type: Utils.StackType, _is_critical: bool, _action_id: StringName, _source: Entity = null, _duration: float = 5.0) -> float:
	printerr("Entity: virtual take_condition_stack() called [", get_path(), "]")
	return -1.0

func take_heal(_heal_amount: float, _is_critical: bool, _action_id: StringName, _source: Entity = null) -> float:
	printerr("Entity: virtual take_heal() called [", get_path(), "]")
	return -1.0

func take_cleanse(_value: float, _is_critical: bool, _action_id: StringName, _source: Entity = null) -> float:
	printerr("Entity: virtual take_cleanse() called [", get_path(), "]")
	return -1.0

func take_dispell(_value: float, _is_critical: bool, _action_id: StringName, _source: Entity = null) -> float:
	printerr("Entity: virtual take_dispell() called [", get_path(), "]")
	return -1.0
#endregion

#region ============================== Private functions ==============================
func _on_entity_fighting_state_changed(new_fighting_state: FightingState) -> void:
	Verbose.debug("Entity [" + entity_name + "] fighting state changed to [" + str(FightingState.keys()[new_fighting_state]) + "]", Verbose.Category.ENTITY)
	match new_fighting_state:
		FightingState.IDLE:
			target_module.stop()
			_stack_handler_module.stop()
		FightingState.FIGHTING:
			target_module.start()
			_stack_handler_module.start()
		FightingState.CELEBRATING: pass
		FightingState.DEAD: pass
		FightingState.UNDEF: pass
#endregion
