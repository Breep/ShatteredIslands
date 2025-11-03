class_name Entity
extends CharacterBody3D

# ============================== Signals ==============================

signal dead(self_ref: Entity)
func signal_death() -> void:
	_is_dead = true
	dead.emit(self)

signal damage_taken(entity_ref: Entity, damage: int, damage_type: Utils.DamageType, is_critical: bool, blocked_by_armor: bool)
func signal_damage_taken(damage: int, damage_type: Utils.DamageType, is_critical: bool, blocked_by_armor: bool) -> void:
	damage_taken.emit(self, damage, damage_type, is_critical, blocked_by_armor)

signal heal_taken(entity_ref: Entity, heal_amount: int)
func signal_heal_taken(heal_amount: int) -> void:
	heal_taken.emit(self, heal_amount)

signal spell_casted(source: Entity, target: Entity, spell_type: Spell.Type)
func signal_spell_casted(target: Entity, spell_type: Spell.Type) -> void:
	spell_casted.emit(self, target, spell_type)

signal stack_taken(source: Entity, stack_type: Utils.StackType, stack_number: int)
func signal_stack_taken(stack_type: Utils.StackType, stack_number: int) -> void:
	stack_taken.emit(self, stack_type, stack_number)

signal auto_attack_started(is_critical: bool)
func signal_auto_attack_started(is_critical: bool) -> void:
	auto_attack_started.emit(is_critical)


# ============================== Public variables ==============================

var _is_dead: bool = false
var is_dead: bool:
	get: return _is_dead

# ============================== Export (Network) ==============================

@export_group("Network")
@export var id: int = -1 # Multiplayer ID of the entity
@export var team: int = -1 # Team number of the entity
@export var battle_id: int = -1 # The id of the battle the entity is in

# ============================== Local Nodes ==============================

@export_group("Stats")
@export var stats: EntityStats
@export var base_stats: EntityStats
@export var stats_manager: EntityStatsManager

@export_group("Registry")
@export var auto_attack_modifier_registry: AutoAttackModifierRegistry

# ============================== Enums ==============================

enum EntityType {
	CHARACTER,
}

# ============================== Constants ==============================

const SIGNAL_NAME_SPAWNED: String = "spawned"

# ============================== Static variables ==============================

static var instance_count: int = 0

# ============================== Node base functions ==============================

func _init() -> void:
	id = instance_count
	instance_count += 1


#func _enter_tree() -> void:
	#if is_node_ready() and battle_id != -1:
		#_recursive_propagate_signal(get_parent(), Entity.SIGNAL_NAME_SPAWNED)

# ============================== Public functions ==============================

func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_position
	direction.y = 0
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)


func get_auto_attack_spawn() -> Node3D:
	return self

# ===== Notifications [VIRTUAL]

func notify_damage_done(_damage: int, _attack_type: Utils.AttackType) -> void:
	printerr("Entity: virtual notice_damage_done() called [", get_path(), "]")

# ===== Actions [VIRTUAL]

func direct_attack(_target: Character, _damage: int, _damage_type: Utils.DamageType) -> void:
	printerr("Entity: virtual direct_attack() called [", get_path(), "]")

func direct_attack_percent(_target: Character, _damage_percent: float, _damage_type: Utils.DamageType, _percent_modifier: Utils.PercentModifier) -> void:
	printerr("Entity: virtual direct_attack_percent() called [", get_path(), "]")

func projectile_attack(_target: Character, _projectile_type: Projectile.ProjectileType, _projectile_spawn: Node3D, _projectile_stats: ProjectileStats) -> void:
	printerr("Entity: virtual projectile_attack() called [", get_path(), "]")

func cast_spell(_target: Entity, _spell_type: Spell.Type, _spell_modifier: Dictionary) -> void:
	printerr("Entity: virtual cast_spell() called [", get_path(), "]")

func cast_ultimate() -> void:
	printerr("Entity: virtual cast_ultimate() called [", get_path(), "]")

func heal(_target: Character, _heal_amount: int) -> void:
	printerr("Entity: virtual heal() called [", get_path(), "]")

func heal_percent(_target: Character, _percent: float, _percent_modifier: Utils.PercentModifier) -> void:
	printerr("Entity: virtual heal_percent() called [", get_path(), "]")

func inflict_condition_stacks(_target: Character, _stacks_number: int, _stack_type: Utils.StackType) -> void:
	printerr("Entity: virtual inflict_condition_stacks() called [", get_path(), "]")

# ===== Interaction [VIRTUAL]

func take_damage(_damage: int, _damage_type: Utils.DamageType, _is_critical: bool = false, _source: Entity = null, _attack_type: Utils.AttackType = Utils.AttackType.UNDEF) -> int:
	printerr("Entity: virtual take_damage() called [", get_path(), "]")
	return -1

func take_damage_percent(_percent: float, _percent_modifier: Utils.PercentModifier, _damage_type: Utils.DamageType, _is_critical: bool = false, _source: Entity = null) -> void:
	printerr("Entity: virtual take_damage_percent() called [", get_path(), "]")

func take_condition_stacks(_stacks_number: int, _stack_type: Utils.StackType, _source: Character = null) -> void:
	printerr("Entity: virtual take_condition_stack() called [", get_path(), "]")

func take_heal(_heal_amount: int, _source: Character = null) -> void:
	printerr("Entity: virtual take_heal() called [", get_path(), "]")

# ============================== Private functions ==============================

func _recursive_propagate_signal(node: Node, signal_name: String) -> void:
	if node == null: return
	if node.has_signal(signal_name):
		node.emit_signal(signal_name, self)
	else:
		_recursive_propagate_signal(node.get_parent(), signal_name)
