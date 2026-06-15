extends Node
class_name SpawnManager

# ============================== Signals ==============================
signal entity_spawned(entity: Entity)
signal projectile_spawned(projectile: Projectile)

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
		_fighting_area.fighting_manager.fight_done.connect(_on_fight_is_over)

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

# `local_space` : quand true, `spawn_transform` est interprété en coordonnées
# locales relatives à `_entities_node` — c'est le cas des formations (EntitySpec),
# pour que la rotation/orientation de l'island se propage aux entités. Les summons
# runtime passent des positions monde déjà résolues → restent en global (false).
func spawn_entity(entity: Entity, spawn_transform: Transform3D, context: EntityContext = null, type := Entity.EntityType.HERO, local_space: bool = false) -> void:
	if entity == null: return

	entity.uid = _entity_counter
	_entity_counter += 1

	if context != null:
		entity.apply_context(context)
	_entities_node.add_child(entity)
	if local_space:
		entity.transform = spawn_transform
	else:
		entity.global_transform = spawn_transform
	_active_entities.append(entity)

	entity_spawned.emit(entity)
	if _fighting_area != null:
		_fighting_area.entity_spawned.emit(entity, type, entity.global_position)


## Adopte une entité déjà présente dans la scène (posée en éditeur pour le proto).
## Lui attribue un UID, applique le contexte, et l'enregistre auprès du SpawnManager,
## sans la détruire/recréer ni la déplacer. La position et tous les @export déjà setés
## en éditeur sont préservés tels quels.
##
## L'entité a déjà eu son _ready (puisqu'elle est déjà dans l'arbre), donc on
## re-câble explicitement ce qui dépend du spawn_manager après l'apply_context.
func adopt_entity(entity: Entity, context: EntityContext = null, type := Entity.EntityType.HERO) -> void:
	if entity == null: return
	if entity in _active_entities:
		Verbose.warn("SpawnManager: entity [" + entity.entity_name + "] already adopted, skipping", Verbose.Category.ENTITY)
		return

	entity.uid = _entity_counter
	_entity_counter += 1

	# Par défaut, si le contexte ne précise pas de spawn_manager, on utilise self.
	# Évite que l'appelant ait à se rappeler de le seter à chaque fois.
	if context != null and context.spawn_manager == null:
		context.spawn_manager = self

	if context != null:
		entity.apply_context(context)
		# apply_context re-connecte les "senders" (damage, heal, projectile, spell,
		# summon, auto_attack) mais pas target — on le fait ici.
		if entity.target != null:
			entity.target.connect_to_spawn_manager(self)
		# _ready de l'entité a déjà tourné, donc _initial_fighting_state_from_context
		# ne sera pas relu. On set l'état explicitement.
		if context.fighting_state != Entity.FightingState.UNDEF:
			entity.fighting_state = context.fighting_state

	_active_entities.append(entity)

	entity_spawned.emit(entity)
	if _fighting_area != null:
		_fighting_area.entity_spawned.emit(entity, type, entity.global_position)


func spawn_spell(spell: Spell) -> void:
	spell.spells_node = _spells_node
	_spells_node.add_child(spell)


## Spawn a transient, purely-cosmetic VFX scene at a world position (no gameplay).
## Auto-frees after `lifetime` seconds — the raw pack scenes don't free themselves.
func spawn_vfx(scene: PackedScene, position: Vector3, lifetime: float = 3.0) -> Node3D:
	if scene == null: return null
	var vfx: Node3D = scene.instantiate() as Node3D
	if vfx == null: return null
	_spells_node.add_child(vfx)
	vfx.global_position = position
	if lifetime > 0.0:
		get_tree().create_timer(lifetime).timeout.connect(vfx.queue_free)
	return vfx


func spawn_projectile(source: Entity, target: Entity, type: Projectile.Type, spawn_node: Node3D, stats: ProjectileStats, spawn_offset: Vector3 = Vector3.ZERO) -> void:
	var scene: PackedScene = Shared.PROJECTILE_SCENES[type]
	if not scene: return

	var proj: Projectile = scene.instantiate()
	proj.name = "Proj_" + str(_projectile_counter)
	proj.uid = _projectile_counter
	_projectile_counter += 1

	proj.init(source, target, stats)
	_projectiles_node.add_child(proj)
	proj.global_position = spawn_node.global_position + spawn_offset
	proj.init_trajectory()
	_active_projectiles.append(proj)
	
	projectile_spawned.emit(proj)
	if _fighting_area != null:
		_fighting_area.projectile_spawned.emit(source, target, type, proj, proj.global_position)
		proj.target_hit.connect(_on_projectile_target_hit.bind(proj.uid))

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
	pass


func _on_projectile_target_hit(target: Entity, gpos: Vector3, projectile_uid: int) -> void:
	_fighting_area.projectile_target_hit.emit(target, gpos, projectile_uid)
