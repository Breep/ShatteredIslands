extends Node # Needs to be a Node 3D to get global_position of areas childs of this manager
class_name SpawnManager

# ============================== Signal ==============================

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== External Export ==============================

@export var _fighting_area: FightingArea

#@export var _entities_node: Node3D
@export var _projectiles_node: Node3D

# ============================== Private variables ==============================

var _projectile_counter: int = 0

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.all_fights_are_over.connect(_on_global_fighting_manager_all_fights_are_over)

# ============================== Public function ==============================

func spawn_projectile(source: Character, target: Character, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	var projectile: Projectile = preload("res://SpellsAndProjectiles/Projectiles/projectile.tscn").instantiate()
	projectile.name = "Projectile_" + str(_projectile_counter)
	projectile.position = _projectiles_node.to_local(projectile_spawn.global_position)
	projectile.stats = projectile_stats
	projectile.source = source
	projectile.target = target
	projectile.battle_id = battle_id
	projectile.id = _projectile_counter
	
	var modifiers: Array[Projectile.ProjectileEffect] = []
	_fighting_area.signal_projectile_spawned(source, target, projectile_type, modifiers)
	_projectile_counter += 1
	_projectiles_node.add_child(projectile)

# ============================== Private functions ==============================

# ============================== Callbacks ==============================

func _on_global_fighting_manager_all_fights_are_over() -> void:
	for child in _projectiles_node.get_children():
		child.queue_free()



 
