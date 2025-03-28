class_name EntityManager
extends Node

signal entity_spawned(entity: Entity)
signal entity_dead(entity: Entity)

# ============================== Private variables ==============================

var _entities: Array[Entity]
var entities: Array[Entity]:
	get: return _entities

# ============================== Node base functions ==============================

func _ready() -> void:
	get_parent().add_user_signal(Entity.SIGNAL_NAME_SPAWNED, ["entity_ref"])
	get_parent().connect(Entity.SIGNAL_NAME_SPAWNED, _on_parent_entity_is_spawned)

# ============================== Private functions ==============================

func _add_entity(who: Entity) -> void:
	_entities.append(who)
	entity_spawned.emit(who)
	who.dead.connect(_on_entity_dead)

# ============================== Callbacks ==============================

# Attached to a custom user signals added my this module to the parent
func _on_parent_entity_is_spawned(who: Entity) -> void:
	print(" EntityManager(", self, "): ", who.name, " is spawned !")
	if _entities.has(who):
		printerr("EntityManager: ", who, "-", who.name, " is spawned more than once")
		return
	
	_add_entity(who)


func _on_entity_dead(who: Entity) -> void:
	_entities.erase(who)
	entity_dead.emit(who)










 
