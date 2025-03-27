class_name EntityManager
extends Node

signal entity_spawned(entity: Entity)

# ============================== Constants ==============================

const SIGNAL_NAME_ENTITY_SPAWNED: String = "entity_is_spawned"

# ============================== Private variables ==============================

var _entities: Array[Entity]
var entities: Array[Entity]:
	get: return _entities

# ============================== Node base functions ==============================

func _ready() -> void:
	get_parent().add_user_signal(SIGNAL_NAME_ENTITY_SPAWNED, ["entity_ref"])
	get_parent().connect(SIGNAL_NAME_ENTITY_SPAWNED, _on_parent_entity_is_spawned)

# ============================== Private functions ==============================

func _add_entity(who: Entity) -> void:
	_entities.append(who)
	entity_spawned.emit(who)

# ============================== Callbacks ==============================

func _on_parent_entity_is_spawned(who: Entity) -> void:
	print(" EntityManager(", self, "): ", who.name, " is spawned !")
	if _entities.has(who):
		printerr("EntityManager: ", who, "-", who.name, " is spawned more than once")
		return
	
	_add_entity(who)












 
