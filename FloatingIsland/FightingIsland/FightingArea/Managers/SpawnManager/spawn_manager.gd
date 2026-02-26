extends Node
class_name SpawnManager

# ============================== Export variables ==============================
@export var _fighting_area: FightingArea
@export var _entities_node: Node3D
@export var _projectiles_node: Node3D
@export var _spells_node: Node3D

# ============================== Private variables ==============================
var _active_entities: Array[Entity] = []
var _active_projectiles: Array[Projectile] = []

var _entity_counter: int = 0
var _projectile_counter: int = 0

# ============================== Node base functions ==============================
func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	if _fighting_area != null and _fighting_area.fighting_manager != null:
		_fighting_area.fighting_manager.fight_is_over.connect(_on_fight_is_over)

# ============================== Public functions (Tick) ==============================

func get_entities() -> Array[Entity]:
	_active_entities = _active_entities.filter(func(e):
		return is_instance_valid(e) and not e.is_queued_for_deletion()
	)
	return _active_entities


func get_projectiles() -> Array[Projectile]:
	_active_projectiles = _active_projectiles.filter(func(p):
		return is_instance_valid(p) and not p.is_queued_for_deletion()
	)
	return _active_projectiles

# ============================== Public functions (Spawning) ==============================

func spawn_entity(entity: Entity, global_pos: Vector3, context: EntityContext = null, type := Entity.EntityType.HERO) -> void:
	if entity == null: return
	
	entity.uid = _entity_counter
	_entity_counter += 1
	
	if context != null:
		entity.apply_context(context)
	_entities_node.add_child(entity)
	entity.global_position = global_pos
	_active_entities.append(entity)
	
	if _fighting_area != null:
		_fighting_area.signal_entity_spawned(entity, type, {})


func spawn_spell(spell: Node3D) -> void:
	_spells_node.add_child(spell)


func spawn_projectile(source: Entity, target: Entity, type: Projectile.Type, spawn_node: Node3D, stats: ProjectileStats) -> void:
	var scene: PackedScene = Shared.PROJECTILE_SCENES[type]
	if not scene: return
	
	var proj: Projectile = scene.instantiate()
	proj.name = "Proj_" + str(_projectile_counter)
	proj.uid = _projectile_counter
	_projectile_counter += 1
	
	proj.init(source, target, stats)
	_projectiles_node.add_child(proj)
	proj.global_position = spawn_node.global_position
	_active_projectiles.append(proj)
	
	if _fighting_area != null:
		_fighting_area.signal_projectile_spawned(source, target, type, proj)

# ============================== Private functions ==============================

func _clear_all() -> void:
	for e in _active_entities: if is_instance_valid(e): e.queue_free()
	for p in _active_projectiles: if is_instance_valid(p): p.queue_free()
	
	_active_entities.clear()
	_active_projectiles.clear()
	_entity_counter = 0
	_projectile_counter = 0

# ============================== Callbacks ==============================
func _on_game_manager_game_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.BUYING:
		_clear_all()

func _on_fight_is_over(_manager, _order) -> void:
	_clear_all()
