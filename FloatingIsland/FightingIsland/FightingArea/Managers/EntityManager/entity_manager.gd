class_name EntityManager
extends Node

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _fighting_area: FightingArea

# ============================== Signals ==============================

signal entity_spawned(entity: Entity)
signal entity_dead(entity: Entity)

# ============================== Private variables ==============================

var _entities: Dictionary[int, Entity] # Key=Entity id, Value=Entity ref
var entities: Dictionary[int, Entity]:
	get: return _entities

var _characters: Dictionary[int, Character] # Key=Entity id, Value=Character ref
var characters: Dictionary[int, Character]:
	get: return _characters

# ============================== Node base functions ==============================

func _ready() -> void:
	get_parent().add_user_signal(Entity.SIGNAL_NAME_SPAWNED, ["entity_ref"])
	get_parent().connect(Entity.SIGNAL_NAME_SPAWNED, _on_parent_entity_is_spawned)
	Events.game_state_changed.connect(_on_events_game_state_changed)

# ============================== Public functions ==============================

func clear() -> void:
	for entity in _entities.values():
		if entity.dead.is_connected(_on_entity_dead):
			entity.dead.disconnect(_on_entity_dead)
	_entities.clear()
	_characters.clear()

# ============================== Private functions ==============================

func _register_entity(who: Entity) -> void:
	_entities[who.id] = who
	if who is Character:
		_characters[who.id] = who
	
	entity_spawned.emit(who)
	who.dead.connect(_on_entity_dead, CONNECT_ONE_SHOT)
	who.damage_taken.connect(_on_entity_damage_taken)

# ============================== Callbacks ==============================

# Attached to a custom user signals added my this module to the parent
func _on_parent_entity_is_spawned(who: Entity) -> void:
	if _entities.has(who.id):
		printerr("EntityManager: ", who, "-", who.name, " is spawned more than once")
		return
	_register_entity(who)


func _on_entity_dead(who: Entity) -> void:
	if not _entities.has(who.id): return
	_entities.erase(who.id)
	entity_dead.emit(who)


func _on_events_game_state_changed(game_state: Game.GameState) -> void:
	if game_state == Game.GameState.BUYING:
		clear()


func _on_entity_damage_taken(entity_ref: Entity, damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	_fighting_area.signal_damage_taken(entity_ref, damage, damage_type, is_critical)






 
