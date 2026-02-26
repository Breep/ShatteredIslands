class_name ChickenManager
extends FamilyManager

# ============================== Constants ==============================

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GIFTED_CHANCE: Array[float] = [25.0, 35.0, 45.0, 55.0]

# ============================== Private variables ==============================

var _chicken_stats: FamilyChickenStats
var _chicken_number: int
var _chicken_spawn_period: float
var _chicken_spawn_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_chicken_stats = _owner.families_stats.chicken
	_chicken_number = 1
	_chicken_spawn_period = 2
	_create_chicken_spawn_timer()

func start() -> void:
	pass
	
func stop() -> void:
	pass
	
func _spawn_chickens() -> void:
	var spawn_location_config := SpawnLocationConfig.create_random_arena()
	for i in _chicken_number:
		_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {})
	
	
func _create_chicken_spawn_timer() -> void:
	_owner.periodic_timer_registry.register(&"Chicken passive", _chicken_spawn_period, _spawn_chickens)
