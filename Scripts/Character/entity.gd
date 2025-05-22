class_name Entity
extends CharacterBody3D

# ============================== Signals ==============================

signal dead(self_ref: Entity)

# ============================== Export (Network) ==============================

@export var id: int = -1 # Multiplayer ID of the entity
@export var team: int = -1 # Team number of the entity
@export var battle_id: int = -1 # The id of the battle the entity is in

# ============================== Enums ==============================

enum EntityType {
	CHARACTER,
}

# ============================== Constants ==============================

const SIGNAL_NAME_SPAWNED: String = "spawned"

# ============================== Node base functions ==============================

func _enter_tree() -> void:
	#print("Character: _enter_tree() [", get_path(), "]")
	if is_node_ready() and battle_id != -1:
		#print("Character: _enter_tree() signal")
		_recursive_propagate_signal(get_parent(), Entity.SIGNAL_NAME_SPAWNED)

# ============================== Private functions ==============================

func _recursive_propagate_signal(node: Node, signal_name: String) -> void:
	if node == null: return
	if node.has_signal(signal_name):
		node.emit_signal(signal_name, self)
	else:
		_recursive_propagate_signal(node.get_parent(), signal_name)
