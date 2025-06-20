class_name Entity
extends CharacterBody3D

# ============================== Signals ==============================

signal dead(self_ref: Entity)
func signal_death() -> void:
	dead.emit(self)

signal damage_taken(entity_ref: Entity, damage: int, damage_type: Utils.DamageType, is_critical: bool)
func signal_damage_taken(damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	damage_taken.emit(self, damage, damage_type, is_critical)

# ============================== Export (Network) ==============================

@export_group("Network")
@export var id: int = -1 # Multiplayer ID of the entity
@export var team: int = -1 # Team number of the entity
@export var battle_id: int = -1 # The id of the battle the entity is in

# ============================== Local Nodes ==============================

@export_group("Stats")
@export var stats: EntityStats

# ============================== Enums ==============================

enum EntityType {
	CHARACTER,
}

# ============================== Constants ==============================

const SIGNAL_NAME_SPAWNED: String = "spawned"

# ============================== Static variables ==============================

static var instance_count: int = 0

# ============================== Node base functions ==============================

func _entity_init() -> void:
	#print("Character: _init() [", get_path(), "] [", instance_count, "]")
	id = instance_count
	instance_count += 1


func _enter_tree() -> void:
	#print("Character: _enter_tree() [", get_path(), "] [", battle_id, "]")
	if is_node_ready() and battle_id != -1:
		#print("Character:      _enter_tree() signal")
		_recursive_propagate_signal(get_parent(), Entity.SIGNAL_NAME_SPAWNED)

# ============================== Public functions ==============================

func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_position
	direction.y = 0
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)


func get_auto_attack_spawn() -> Node3D:
	return self

# ===== Actions

# ===== Interaction [VIRTUAL]

func take_damage(_damage: int, _damage_type: Utils.DamageType, _is_critical: bool, _source: Entity = null) -> void:
	printerr("Entity: virtual take_damage() called [", get_path(), "]")

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
