class_name ChickenManager
extends FamilyManager

# ============================== Constants ==============================

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GIFTED_CHANCES: Array[float] = [0, 25.0, 35.0, 45.0, 55.0]
const SPAWN_PERIODS: Array[float] = [12.0, 6.0, 5.5, 5.0, 4.5]
const START_CHICKENS: Array[int] = [0, 2, 3, 4, 6]

const GIFTED_AD_RATIOS: Array[float] = [0.15, 0.20, 0.25, 0.3]
const GIFTED_AS_RATIOS: Array[float] = [0.15, 0.20, 0.25, 0.3]

const GIFTED_FAMILY_WEIGHTS: Array[float] = [0, 1, 4, 9, 16]

# ============================== Private variables ==============================

var _chicken_stats: FamilyChickenStats
var _chicken_number: int
var _chicken_spawn_period: float
var _gifted_families_ratio: Dictionary[Family.FamilyType, float]
var _families_level: Dictionary[Family.FamilyType, int]
var _gifted_types: Array[Chicken.Type]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_chicken_stats = _owner.families_stats.chicken


func start() -> void:
	
	_families_level = _owner.get_families_level()
	_init_gifted_types()
	
	
	
	_chicken_number = START_CHICKENS[level]
	_spawn_chickens()
	
	_chicken_number = 1
	if level >= 1 :
		_chicken_spawn_period = SPAWN_PERIODS[level] - _chicken_stats.spawn_period_decrease
		_create_chicken_spawn_timer()
	
func stop() -> void:
	pass
	
func _init_gifted_types() -> void:
	for family_type in _families_level:
		for i in GIFTED_FAMILY_WEIGHTS[_families_level[family_type]]:
			match family_type:
				Family.FamilyType.ATTACK: _gifted_types.append(Chicken.Type.GIFTED_ATTACK)
				Family.FamilyType.FIRE: _gifted_types.append(Chicken.Type.GIFTED_FIRE)
				Family.FamilyType.DEFENSE: _gifted_types.append(Chicken.Type.GIFTED_SHIELD)
				Family.FamilyType.LIGHTNING: _gifted_types.append(Chicken.Type.GIFTED_LIGHTNING)
				Family.FamilyType.SERENITY: _gifted_types.append(Chicken.Type.GIFTED_LIGHT)
				Family.FamilyType.POISON: _gifted_types.append(Chicken.Type.GIFTED_POISON)
				Family.FamilyType.LIFE: _gifted_types.append(Chicken.Type.GIFTED_COLOSSUS)
				Family.FamilyType.NECROSIS: _gifted_types.append(Chicken.Type.GIFTED_NECROSIS)


func _spawn_chickens() -> void:
	for i in _chicken_number:
		_spawn_chicken(_randomize_chicken())


func _create_chicken_spawn_timer() -> void:
	_owner.periodic_timer_registry.register(&"Chicken passive", _chicken_spawn_period, _spawn_chickens, true)


func _randomize_chicken() -> Chicken.Type:
	if Utils.is_randomize_modifier_active(GIFTED_CHANCES[level], _owner.battle_id):
		return Utils.pick_random(_gifted_types, _owner.battle_id)
	return Chicken.Type.BASIC


func _spawn_chicken(chicken_type: Chicken.Type) -> void:
	var spawn_location_config := SpawnLocationConfig.create_random_arena()
	match chicken_type:
		Chicken.Type.BASIC: 
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config,{})
		Chicken.Type.GIFTED_ATTACK:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_ATTACK,
				"ad": _owner.stats.attack_damage * GIFTED_AD_RATIOS[_families_level[Family.FamilyType.ATTACK]],
				"as": _owner.stats.attack_speed * GIFTED_AS_RATIOS[_families_level[Family.FamilyType.ATTACK]],
				})
