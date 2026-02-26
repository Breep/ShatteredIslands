class_name EntityManager
extends Node

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _fighting_area: FightingArea
@export var _scanner_area: Area3D

# ============================== Private variables ==============================

var _entities: Dictionary[int, Entity] # Key=Entity id, Value=Entity ref
var entities: Dictionary[int, Entity]:
	get: return _entities

var _heroes: Dictionary[int, Hero] # Key=Entity id, Value=Hero ref
var heroes: Dictionary[int, Hero]:
	get: return _heroes

var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	if _scanner_area == null:
		Verbose.error("Scanning area unset [" + str(get_path()) + "]", Verbose.Category.ENTITY_MANAGER)
		return
	
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	_scanner_area.body_entered.connect(_on_scanner_area_body_entered)
	_scanner_area.body_exited.connect(_on_scanner_area_body_exited)

# ============================== Public functions ==============================

func clear() -> void:
	Verbose.debug("clear()", Verbose.Category.ENTITY_MANAGER)
	for entity: Entity in _entities.values():
		if entity != null:
			if entity.spell_casted.is_connected(_on_entity_spell_casted):
				entity.spell_casted.disconnect(_on_entity_spell_casted)
			if entity.died.is_connected(_on_entity_died):
				entity.died.disconnect(_on_entity_died)
			if entity.action_done.is_connected(_on_entity_action_done):
				entity.action_done.disconnect(_on_entity_action_done)
			if entity.interaction_received.is_connected(_on_entity_interaction_received):
				entity.interaction_received.disconnect(_on_entity_interaction_received)
	_entities.clear()
	_heroes.clear()


func get_entity(entity_id: int) -> Entity:
	if not _entities.has(entity_id):
		Verbose.error("Can't find specified entity | " + str(entity_id) + " | " + str(_entities.keys()), Verbose.Category.ENTITY_MANAGER)
		return null
	
	return _entities[entity_id]

# ============================== Private functions ==============================

func _register_entity(entity: Entity) -> void:
	if _entities.has(entity.uid):
		Verbose.error("Entity " + entity.name + " (" + str(entity.uid) + ") is already registered. Existing: " + _entities[entity.uid].name + " [" + str(get_path()) + "]", Verbose.Category.ENTITY_MANAGER)
		return
	
	_entities[entity.uid] = entity
	if entity is Hero:
		_heroes[entity.uid] = entity
	
	entity.spell_casted.connect(_on_entity_spell_casted.bind(entity))
	entity.action_done.connect(_on_entity_action_done.bind(entity))
	entity.interaction_received.connect(_on_entity_interaction_received.bind(entity))
	entity.died.connect(_on_entity_died.bind(entity))
	entity.connect_to_fighting_area(_fighting_area)


func _kick_entity(entity: Entity) -> void:
	if entity.spell_casted.is_connected(_on_entity_spell_casted): entity.spell_casted.disconnect(_on_entity_spell_casted)
	if entity.died.is_connected(_on_entity_died): entity.died.disconnect(_on_entity_died)
	if entity.action_done.is_connected(_on_entity_action_done): entity.action_done.disconnect(_on_entity_action_done)
	if entity.interaction_received.is_connected(_on_entity_interaction_received): entity.interaction_received.disconnect(_on_entity_interaction_received)
	entities.erase(entity.uid)
	if _heroes.has(entity.uid): _heroes.erase(entity.uid)

# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.BUYING:
			_is_active = false
			clear()
		GameManager.GameState.FIGHTING:
			_is_active = true


func _on_entity_spell_casted(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary, source: Entity) -> void:
	_fighting_area.signal_spell_casted(source, target, spell_type, spell_modifier)


func _on_entity_action_done(target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool, source: Entity) -> void:
	_fighting_area.signal_action_done(source, target, action_type, action_id, value, is_critical)


func _on_entity_interaction_received(source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool, entity_ref: Entity) -> void:
	_fighting_area.signal_interaction_received(entity_ref, source, action_type, action_id, value, is_critical)


func _on_entity_died(entity: Entity) -> void:
	_fighting_area.signal_entity_died(entity)


func _on_scanner_area_body_entered(body: Node3D) -> void:
	if not _is_active: return
	if not body is Entity:
		Verbose.error("A body detected has an Entity mask but is not an entity: [" + str(body.get_path()) + "]", Verbose.Category.ENTITY_MANAGER)
		return
	_register_entity(body)
 

func _on_scanner_area_body_exited(body: Node3D) -> void:
	if not _is_active: return
	if not body is Entity:
		Verbose.error("A body detected has an Entity mask but is not an entity: [" + str(body.get_path()) + "]", Verbose.Category.ENTITY_MANAGER)
		return
	_kick_entity(body)
