class_name ChickenManager
extends FamilyManager

# ============================== Constants ==============================

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GIFTED_CHANCE: Array[float] = [0, 25.0, 35.0, 45.0, 55.0]
const SPAWN_PERIOD: Array[float] = [12.0, 6.0, 5.5, 5.0, 4.5]
const START_CHICKENS: Array[int] = [0, 2, 3, 4, 6]

# ============================== Private variables ==============================

var _chicken_stats: FamilyChickenStats
var _chicken_number: int
var _chicken_spawn_period: float
var _chicken_spawn_timer: Timer
var _current_lvl: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_lvl = level
	_chicken_stats = _owner.families_stats.chicken
	_chicken_spawn_period = SPAWN_PERIOD[_current_lvl]
	_chicken_number = 1
	_create_chicken_spawn_timer()
	print(_owner.name, " chicken level: ", _current_lvl)
	

func start() -> void:
	_chicken_number = START_CHICKENS[_current_lvl]
	_spawn_chickens()
	_chicken_number = 1
	
func stop() -> void:
	pass
	
func _spawn_chickens() -> void:
	var spawn_location_config := SpawnLocationConfig.create_random_arena()
	for i in _chicken_number:
		_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {})
	
func _create_chicken_spawn_timer() -> void:
	_owner.periodic_timer_registry.register(&"Chicken passive", _chicken_spawn_period, _spawn_chickens)
