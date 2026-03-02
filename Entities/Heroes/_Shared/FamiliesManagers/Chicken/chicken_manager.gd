class_name ChickenManager
extends FamilyManager

# ============================== Constants ==============================

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GIFTED_CHANCE: Array[float] = [0, 25.0, 35.0, 45.0, 55.0]
const SPAWN_PERIOD: Array[float] = [12.0, 6.0, 5.5, 5.0, 4.5]
const START_CHICKENS: Array[int] = [0, 2, 3, 4, 6]

const GIFTED_AD_RATIO: Array[float] = [0.15, 0.20, 0.25, 0.3]
const GIFTED_AS_RATIO: Array[float] = [0.15, 0.20, 0.25, 0.3]

# ============================== Private variables ==============================

var _chicken_stats: FamilyChickenStats
var _chicken_number: int
var _chicken_spawn_period: float
var _chicken_spawn_timer: Timer
var _current_lvl: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_chicken_stats = _owner.families_stats.chicken


func start() -> void:
	_current_lvl = level
	#_gifted_chance = GIFTED_CHANCE[level]
	_chicken_number = START_CHICKENS[_current_lvl]
	
	_spawn_chickens()
	_chicken_number = 1
	if _current_lvl >= 1 :
		_chicken_spawn_period = SPAWN_PERIOD[_current_lvl] - _chicken_stats.spawn_period_decrease
		_create_chicken_spawn_timer()
	
func stop() -> void:
	pass
	
func _spawn_chickens() -> void:
	# TODO demander à Clément comment gérer le random pour les gifted
	for i in _chicken_number:
		var chicken_type = "toto"
		_spawn_chicken(chicken_type)
		
	
func _create_chicken_spawn_timer() -> void:
	_owner.periodic_timer_registry.register(&"Chicken passive", _chicken_spawn_period, _spawn_chickens, true)
	


func _randomize_chicken() -> void:
	
	Utils.is_randomize_modifier_active(100, _owner.battle_id)

func _spawn_chicken(chicken_type: Chicken.Type) -> void:
	var spawn_location_config := SpawnLocationConfig.create_random_arena()
	match chicken_type:
		Chicken.Type.BASIC: 
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config,{})
		Chicken.Type.GIFTED_ATTACK:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_ATTACK,
				"ad": _owner.stats.attack_damage * GIFTED_AD_RATIO[_current_lvl],
				"as": _owner.stats.attack_speed * GIFTED_AS_RATIO[_current_lvl],
				})
