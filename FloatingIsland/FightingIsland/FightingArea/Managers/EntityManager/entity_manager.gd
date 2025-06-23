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
		if entity.damage_taken.is_connected(_on_entity_damage_taken):
			entity.damage_taken.disconnect(_on_entity_damage_taken)
		if entity.spell_casted.is_connected(_on_entity_spell_casted):
			entity.spell_casted.disconnect(_on_entity_spell_casted)
	_entities.clear()
	_characters.clear()

# ============================== Private functions ==============================

func _register_entity(who: Entity) -> void:
	_entities[who.id] = who
	if who is Character:
		_characters[who.id] = who
	
	entity_spawned.emit(who)
	who.damage_taken.connect(_on_entity_damage_taken)
	who.spell_casted.connect(_on_entity_spell_casted)

# ============================== Callbacks ==============================

# Attached to a custom user signals added by this module to the parent
func _on_parent_entity_is_spawned(who: Entity) -> void: # TODO ça peut être simplifié en mettant une Area3D sur l'entity manager qui scan la zone de combat
	if _entities.has(who.id):
		printerr("EntityManager: ", who, "-", who.name, " is spawned more than once")
		return
	_register_entity(who)


func _on_events_game_state_changed(game_state: Game.GameState) -> void:
	if game_state == Game.GameState.BUYING:
		clear()


func _on_entity_damage_taken(entity_ref: Entity, damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	_fighting_area.signal_damage_taken(entity_ref, damage, damage_type, is_critical)


func _on_entity_spell_casted(entity_ref: Entity, target: Entity, spell_type: Spell.Type) -> void:
	_fighting_area.signal_spell_casted(entity_ref, target, spell_type)



 
