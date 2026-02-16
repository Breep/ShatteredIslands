extends Node # Needs to be a Node 3D to get global_position of areas childs of this manager
class_name SpawnManager

# ============================== Signal ==============================

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== External Export ==============================

@export var _fighting_area: FightingArea

@export var _entities_node: Node3D
@export var _projectiles_node: Node3D
@export var _spells_node: Node3D

# ============================== Private variables ==============================

var _projectile_counter: int = 0

# ============================== Node base functions ==============================

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	if _fighting_area != null:
		_fighting_area.fighting_manager.fight_is_over.connect(_on_fighting_area_fighting_manager_fight_is_over)

# ============================== Public function ==============================

func get_live_projectiles() -> Array[Node]:
	return _projectiles_node.get_children()


func spawn_projectile(source: Entity, target: Entity, projectile_type: Projectile.Type, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	# Get the correct projectile scene
	var projectile_scene: PackedScene = Shared.PROJECTILE_SCENES[projectile_type]
	if not projectile_scene:
		push_error("SpawnManager: No scene found for projectile type ", projectile_type)
		return
	
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.name = "Projectile_" + str(_projectile_counter)
	projectile.init(source, target, projectile_stats)
	projectile.position = _projectiles_node.to_local(projectile_spawn.global_position)
	
	if _fighting_area != null:
		_fighting_area.signal_projectile_spawned(source, target, projectile_type, [], projectile)
	
	_projectile_counter += 1
	_projectiles_node.add_child(projectile)


func spawn_spell(spell: Node3D) -> void:
	_spells_node.add_child(spell)


func spawn_entity(entity: Entity, entity_spawn_global_position: Vector3, context: EntityContext = null) -> void:
	if entity == null:
		push_error("SpawnManager: Trying to spawn a <null> entity")
		return

	# Assign a server-authoritative network ID
	# NOTE: Summons are only spawned on the server (combat simulation is server-only).
	# Clients don't have these entities, so battle logs referencing summon IDs will fail
	# to resolve on clients until a summon replication system is implemented.
	if entity.id == -1:
		entity.id = Entity.generate_network_id()

	if context != null:
		entity.apply_context(context)

	_entities_node.add_child(entity)
	if entity_spawn_global_position != null:
		entity.global_position = entity_spawn_global_position

# ============================== Private functions ==============================

func _clear_all() -> void:
	for projectile in _projectiles_node.get_children():
		projectile.queue_free()
	for spell in _spells_node.get_children():
		spell.queue_free()

# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.BUYING:
		_clear_all()


func _on_fighting_area_fighting_manager_fight_is_over(_self_ref: FightingManager, _winner_teams_order: Array[int]) -> void:
	_clear_all()
