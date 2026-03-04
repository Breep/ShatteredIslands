class_name ChickenManager
extends FamilyManager

# ============================== Constants ==============================

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GIFTED_CHANCES: Array[float] = [0, 25.0, 35.0, 45.0, 55.0]
const SPAWN_PERIODS: Array[float] = [12.0, 6.0, 5.5, 5.0, 4.5]
const START_CHICKENS: Array[int] = [0, 2, 3, 4, 6]

# Chicken gifted attack stats
const GIFTED_AD_RATIOS: Array[float] = [0.15, 0.20, 0.25, 0.3]
const GIFTED_AS_RATIOS: Array[float] = [0.15, 0.20, 0.25, 0.3]

# Chicken gifted poison stats
const GIFTED_POISON_RATIO: Array[float] = [0.10, 0.15, 0.20, 0.25]
const GIFTED_POISON_STACKS: Array[int] = [1, 1, 2, 2]

# Chicken gifted colossus stats
const GIFTED_COLOSSUS_HPMAX_RATIOS: Array[float] = [0.10, 0.15, 0.20, 0.25]

# Chicken gifted light stats
const GIFTED_LIGHT_REGEN_RATIOS: Array[float] = [0.04, 0.06, 0.08, 0.10]
const GIFTED_LIGHT_INHERITED_HEAL: Array[float] = [0.3, 0.5, 0.7, 1.0]

# Chicken gifted shield stats
const GIFTED_SHIELD_BONUS_SPAWN: Array[int] = [20, 30, 40, 50]
const GIFTED_SHIELD_PER_ATTACK: Array[int] = [10, 15, 20, 30]
const GIFTED_SHIELD_INHERITED_SHIELD: Array[float] = [0.3, 0.5, 0.7, 1.0]

# To roll the type of Chicken Gifted
const GIFTED_FAMILY_WEIGHTS: Array[float] = [0, 1, 4, 9, 16]

# ============================== Private variables ==============================

var _chicken_stats: FamilyChickenStats
var _chicken_number: int
var _chicken_spawn_period: float
var _gifted_families_ratio: Dictionary[Family.Type, float]
var _families_level: Dictionary[Family.Type, int]
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
				Family.Type.WARRIOR: _gifted_types.append(Chicken.Type.GIFTED_ATTACK)
				Family.Type.ARDENT_CELESTIAL: _gifted_types.append(Chicken.Type.GIFTED_FIRE)
				Family.Type.ENGINEER: _gifted_types.append(Chicken.Type.GIFTED_SHIELD)
				Family.Type.LIGHTNING: _gifted_types.append(Chicken.Type.GIFTED_LIGHTNING)
				Family.Type.LIGHT: _gifted_types.append(Chicken.Type.GIFTED_LIGHT)
				Family.Type.POISON: _gifted_types.append(Chicken.Type.GIFTED_POISON)
				Family.Type.COLOSSUS: _gifted_types.append(Chicken.Type.GIFTED_COLOSSUS)
				Family.Type.NECROSIS: _gifted_types.append(Chicken.Type.GIFTED_NECROSIS)


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
				"ad": _owner.stats.attack_damage * GIFTED_AD_RATIOS[_families_level[Family.Type.WARRIOR]-1],
				"as": _owner.stats.attack_speed * GIFTED_AS_RATIOS[_families_level[Family.Type.WARRIOR]-1],
				})
		Chicken.Type.GIFTED_POISON:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_POISON,
				"ratio": GIFTED_POISON_RATIO[_families_level[Family.Type.POISON]-1],
				"number": GIFTED_POISON_STACKS[_families_level[Family.Type.POISON]-1]
				})
		Chicken.Type.GIFTED_COLOSSUS:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_COLOSSUS,
				"hpmax": _owner.stats.health_max * GIFTED_COLOSSUS_HPMAX_RATIOS[_families_level[Family.Type.COLOSSUS]-1]
			})
		Chicken.Type.GIFTED_LIGHT:
			var bonus_heal: float = _owner.stats.get_stat(EntityStats.StatType.STRENGTH, Utils.ActionType.UTILITY_HEAL)
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_LIGHT,
				"ratio_regen": GIFTED_LIGHT_REGEN_RATIOS[_families_level[Family.Type.LIGHT]-1],
				"inherited_heal_ratio": bonus_heal * GIFTED_LIGHT_INHERITED_HEAL[_families_level[Family.Type.LIGHT]-1]
			})
		Chicken.Type.GIFTED_SHIELD:
			var bonus_shield: float = _owner.stats.get_stat(EntityStats.StatType.STRENGTH, Utils.ActionType.STACK_SHIELD)
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_SHIELD,
				"shield_per_attack": GIFTED_SHIELD_PER_ATTACK[_families_level[Family.Type.ENGINEER]-1],
				"bonus_spawn": GIFTED_SHIELD_BONUS_SPAWN[_families_level[Family.Type.ENGINEER]-1],
				"shield_strength_inherited": bonus_shield * GIFTED_SHIELD_INHERITED_SHIELD[_families_level[Family.Type.ENGINEER]-1]
			})
			
			
