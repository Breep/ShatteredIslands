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

var _characters: Dictionary[int, Character] # Key=Entity id, Value=Character ref
var characters: Dictionary[int, Character]:
	get: return _characters

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
	for entity: Entity in _entities.values():
		if entity != null:
			if entity.damage_taken.is_connected(_on_entity_damage_taken):
				entity.damage_taken.disconnect(_on_entity_damage_taken)
			if entity.spell_casted.is_connected(_on_entity_spell_casted):
				entity.spell_casted.disconnect(_on_entity_spell_casted)
			if entity.stack_taken.is_connected(_on_entity_stack_taken):
				entity.stack_taken.disconnect(_on_entity_stack_taken)
			if entity.died.is_connected(_on_entity_died):
				entity.died.disconnect(_on_entity_died)
			if entity.action_done.is_connected(_on_entity_action_done):
				entity.action_done.disconnect(_on_entity_action_done)
	_entities.clear()
	_characters.clear()


func get_entity(entity_id: int) -> Entity:
	if not _entities.has(entity_id):
		Verbose.error("Can't find specified entity | " + str(entity_id) + " | " + str(_entities.keys()), Verbose.Category.ENTITY_MANAGER)
		return null
	
	return _entities[entity_id]

# ============================== Private functions ==============================

func _register_entity(entity: Entity) -> void:
	if _entities.has(entity.id):
		printerr("EntityManager: Entity ", entity.name, " is already registered [", get_path(), "]")
		return
	
	_entities[entity.id] = entity
	if entity is Character:
		_characters[entity.id] = entity
	
	
	entity.damage_taken.connect(_on_entity_damage_taken)
	entity.spell_casted.connect(_on_entity_spell_casted)
	entity.stack_taken.connect(_on_entity_stack_taken)
	entity.action_done.connect(_on_entity_action_done)
	entity.died.connect(_on_entity_died)
	entity.connect_to_fighting_area(_fighting_area)


func _kick_entity(entity: Entity) -> void:
	if entity.damage_taken.is_connected(_on_entity_damage_taken): entity.damage_taken.disconnect(_on_entity_damage_taken)
	if entity.spell_casted.is_connected(_on_entity_spell_casted): entity.spell_casted.disconnect(_on_entity_spell_casted)
	if entity.stack_taken.is_connected(_on_entity_stack_taken): entity.stack_taken.disconnect(_on_entity_stack_taken)
	if entity.died.is_connected(_on_entity_died): entity.died.disconnect(_on_entity_died)
	if entity.action_done.is_connected(_on_entity_action_done): entity.action_done.disconnect(_on_entity_action_done)
	entities.erase(entity.id)
	if _characters.has(entity.id): _characters.erase(entity.id)

# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(game_state: Game.GameState) -> void:
	if game_state == Game.GameState.FIGHTING_CELEBRATING:
		_is_active = false
		clear()
	if game_state == Game.GameState.FIGHTING_POSITIONING:
		_is_active = true


func _on_entity_damage_taken(entity: Entity, damage: float, damage_type: Utils.DamageType, is_critical: bool, blocked_by_armor: bool) -> void:
	_fighting_area.signal_damage_taken(entity, damage, damage_type, is_critical, blocked_by_armor)


func _on_entity_spell_casted(entity: Entity, target: Entity, spell_type: Spell.Type) -> void:
	_fighting_area.signal_spell_casted(entity, target, spell_type)


func _on_entity_stack_taken(entity: Entity, stack_type: Utils.StackType, stack_number: float, is_critical: bool) -> void:
	_fighting_area.signal_stack_taken(entity, stack_type, stack_number, is_critical)


func _on_entity_action_done(source: Entity, target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	_fighting_area.signal_action_done(source, target, action_type, action_id, value, is_critical)


func _on_entity_died(entity: Entity) -> void:
	_fighting_area.signal_entity_died(entity)


func _on_scanner_area_body_entered(body: Node3D) -> void:
	if not _is_active: return
	if not body is Entity:
		printerr("EntityManager: A body detected has an Entity mask but is not an entity: [", body.get_path(), "]")
		return
	_register_entity(body)
 

func _on_scanner_area_body_exited(body: Node3D) -> void:
	if not _is_active: return
	if not body is Entity:
		printerr("EntityManager: A body detected has an Entity mask but is not an entity: [", body.get_path(), "]")
		return
	_kick_entity(body)
