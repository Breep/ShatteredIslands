class_name EntityManager
extends Node

signal entity_spawned(entity: Entity)
signal entity_dead(entity: Entity)

# ============================== Private variables ==============================

var _entities: Dictionary[int, Entity] # Key=Entity id, Value=Entity ref
var entities: Dictionary[int, Entity]:
	get: return _entities

var _reverse_entities: Dictionary[Entity, int] # Key=Entity ref, Value=Entity id
var reverse_entities: Dictionary[Entity, int]:
	get: return _reverse_entities

# ============================== Node base functions ==============================

func _ready() -> void:
	get_parent().add_user_signal(Entity.SIGNAL_NAME_SPAWNED, ["entity_ref"])
	get_parent().connect(Entity.SIGNAL_NAME_SPAWNED, _on_parent_entity_is_spawned)

# ============================== Private functions ==============================

func _register_entity(who: Entity) -> void:
	_entities[who.id] = who
	_reverse_entities[who] = who.id
	entity_spawned.emit(who)
	who.dead.connect(_on_entity_dead)

# ============================== Callbacks ==============================

# Attached to a custom user signals added my this module to the parent
func _on_parent_entity_is_spawned(who: Entity) -> void:
	if _entities.has(who):
		printerr("EntityManager: ", who, "-", who.name, " is spawned more than once")
		return
	_register_entity(who)


func _on_entity_dead(who: Entity) -> void:
	_entities.erase(who)
	_reverse_entities.erase(who.id)
	entity_dead.emit(who)










 
