class_name EntitySignalRelay
extends Node

# Relai de signaux : connecte les signaux de combat de chaque entité (action_done,
# action_received, auto_attack_launched, spell_casted, died) et les ré-émet sur la
# FightingArea pour ses consommateurs (BattleWriter…). Tient aussi un index uid→entity
# pour le lookup (BattleReader). Ne gère PAS le cycle de vie des entités : la source de
# vérité est le SpawnManager, dont on suit le signal entity_spawned pour s'abonner.

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _fighting_area: FightingArea

# ============================== Private variables ==============================

var _entities: Dictionary[int, Entity] # Key=Entity uid, Value=Entity ref
var entities: Dictionary[int, Entity]:
	get: return _entities

var _heroes: Dictionary[int, Entity] # Key=Entity uid, Value=hero Entity ref
var heroes: Dictionary[int, Entity]:
	get: return _heroes

# ============================== Node base functions ==============================

func _ready() -> void:
	if _fighting_area == null or _fighting_area.spawn_manager == null:
		Verbose.error("EntitySignalRelay: no SpawnManager to source entities from [" + str(get_path()) + "]", Verbose.Category.ENTITY_MANAGER)
		return
	# Source de vérité : chaque entité spawnée s'enregistre ici via le SpawnManager.
	_fighting_area.spawn_manager.entity_spawned.connect(_register_entity)

# ============================== Public functions ==============================

func clear() -> void:
	Verbose.debug("clear()", Verbose.Category.ENTITY_MANAGER)
	for entity: Entity in _entities.values():
		if is_instance_valid(entity):
			_disconnect_entity(entity)
	_entities.clear()
	_heroes.clear()


func get_entity(entity_id: int) -> Entity:
	if not _entities.has(entity_id):
		Verbose.error("Can't find specified entity | " + str(entity_id) + " | " + str(_entities.keys()), Verbose.Category.ENTITY_MANAGER)
		return null

	return _entities[entity_id]

# ============================== Private functions ==============================

func _register_entity(entity: Entity) -> void:
	if entity == null: return
	if _entities.has(entity.uid):
		Verbose.error("Entity " + entity.name + " (" + str(entity.uid) + ") is already registered. Existing: " + _entities[entity.uid].name + " [" + str(get_path()) + "]", Verbose.Category.ENTITY_MANAGER)
		return

	_entities[entity.uid] = entity
	if entity.is_hero():
		_heroes[entity.uid] = entity

	entity.spell_casted.connect(_on_entity_spell_casted.bind(entity))
	entity.action_done.connect(_on_entity_action_done.bind(entity))
	entity.action_received.connect(_on_entity_interaction_received.bind(entity))
	entity.auto_attack_launched.connect(_on_entity_auto_attack_launched.bind(entity))
	entity.died.connect(_on_entity_died.bind(entity))
	# Désinscription dirigée par le cycle de vie de l'entité (mort/despawn/teardown).
	entity.tree_exited.connect(_on_entity_tree_exited.bind(entity))
	entity.connect_to_fighting_area(_fighting_area)


func _disconnect_entity(entity: Entity) -> void:
	if entity.spell_casted.is_connected(_on_entity_spell_casted): entity.spell_casted.disconnect(_on_entity_spell_casted)
	if entity.action_done.is_connected(_on_entity_action_done): entity.action_done.disconnect(_on_entity_action_done)
	if entity.action_received.is_connected(_on_entity_interaction_received): entity.action_received.disconnect(_on_entity_interaction_received)
	if entity.auto_attack_launched.is_connected(_on_entity_auto_attack_launched): entity.auto_attack_launched.disconnect(_on_entity_auto_attack_launched)
	if entity.died.is_connected(_on_entity_died): entity.died.disconnect(_on_entity_died)
	if entity.tree_exited.is_connected(_on_entity_tree_exited): entity.tree_exited.disconnect(_on_entity_tree_exited)

# ============================== Callbacks ==============================

func _on_entity_tree_exited(entity: Entity) -> void:
	_entities.erase(entity.uid)
	_heroes.erase(entity.uid)


func _on_entity_spell_casted(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary, source: Entity) -> void:
	_fighting_area.spell_casted.emit(source, target, spell_type, spell_modifier)


func _on_entity_action_done(target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool, source: Entity) -> void:
	_fighting_area.action_done.emit(source, target, action_type, action_id, value, is_critical)


func _on_entity_interaction_received(source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool, entity_ref: Entity) -> void:
	_fighting_area.action_received.emit(entity_ref, source, action_type, action_id, value, is_critical)


func _on_entity_auto_attack_launched(target: Entity, source: Entity) -> void:
	_fighting_area.auto_attack_launched.emit(source, target)


func _on_entity_died(entity: Entity) -> void:
	_fighting_area.entity_died.emit(entity)
