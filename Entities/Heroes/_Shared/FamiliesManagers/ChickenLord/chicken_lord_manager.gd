class_name ChickenLordManager
extends FamilyManager

# ============================== Constants ==============================

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GIFTED_CHANCES: Array[float] = [0, 25.0, 35.0, 45.0, 55.0]

const P_PERIODIC_SPAWN_PERIODS: Array[float] = [12.0, 6.0, 5.5, 5.0, 4.5]
const P_PERIODIC_SPAWN_CHICKEN_NUMBERS: Array[int] = [0, 1, 1, 1, 1]
const P_START_CHICKENS: Array[int] = [0, 2, 3, 4, 6]


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

# Chicken gifted ardent celestial stats
const GIFTED_ARDENT_CELESTIAL_IGNITE_STACKS: Array[int] = [10, 15, 20, 30]

# Chicken gifted storm caller stats
const GIFTED_STORM_CALLER_CRIT_CHANCE_RATIO: Array[float] = [0.30, 0.40, 0.50, 0.60]
const GIFTED_STORM_CALLER_CRIT_MULT_RATIO: Array[float] = [0.30, 0.40, 0.50, 0.60]

# To roll the type of Chicken Gifted
const GIFTED_FAMILY_WEIGHTS: Array[float] = [0, 1, 4, 9, 16]

#region ============================== Private variables ==============================
var _chicken_lord_stats: FamilyChickenLordStats
var _gifted_chance: float
var _families_level: Dictionary[Family.Type, int]
var _gifted_types: Array[Chicken.Type]
var _alive_ally_chickens: Array[Chicken]
var _twins_chance: float # relative to Chicken Twins card

var _dead_chicken_count: int
var _alive_chicken_count: int
#endregion

#region ============================== Node base function ==============================
func _ready() -> void:
	_chicken_lord_stats = _owner.families_stats.chicken_lord
#endregion

#region ============================== public API ==============================
func start() -> void:
	_families_level = _owner.get_families_level()
	_init_gifted_types()
	
	_gifted_chance = GIFTED_CHANCES[level] + _chicken_lord_stats.gifted_chance_increase
	if level >= 1 :
		_start_passive()
	
	_owner.target_module.new_entity_detected.connect(_on_owner_target_module_new_entity_detected)
	
	for entity in _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES):
		if entity is Chicken and entity.team == _owner.team:
			_on_chicken_spawned(entity)


func stop() -> void:
	pass
#endregion


func _init_gifted_types() -> void:
	for family_type in _families_level:
		for i in GIFTED_FAMILY_WEIGHTS[_families_level[family_type]]:
			match family_type:
				Family.Type.WARRIOR: _gifted_types.append(Chicken.Type.GIFTED_ATTACK)
				Family.Type.ARDENT_CELESTIAL: _gifted_types.append(Chicken.Type.GIFTED_ARDENT_CELESTIAL)
				Family.Type.ENGINEER: _gifted_types.append(Chicken.Type.GIFTED_ENGINEER)
				Family.Type.STORM_CALLER: _gifted_types.append(Chicken.Type.GIFTED_STORM_CALLER)
				Family.Type.LIGHT: _gifted_types.append(Chicken.Type.GIFTED_LIGHT)
				Family.Type.POISON: _gifted_types.append(Chicken.Type.GIFTED_POISON)
				Family.Type.COLOSSUS: _gifted_types.append(Chicken.Type.GIFTED_COLOSSUS)
				Family.Type.NECROSIS: _gifted_types.append(Chicken.Type.GIFTED_NECROSIS)


#region ============================== PASSIVE ==============================
func _start_passive() -> void:
	_spawn_n_chickens(P_START_CHICKENS[level])
	var spawn_period: float = P_PERIODIC_SPAWN_PERIODS[level] - _chicken_lord_stats.spawn_period_decrease # Rajouter un check
	var chicken_number: int = P_PERIODIC_SPAWN_CHICKEN_NUMBERS[level]
	_owner.periodic_timer_registry.register(&"Chicken passive", spawn_period, _spawn_n_chickens.bind(chicken_number), true)
	
	var spawn_loc := SpawnLocationConfig.create_arena_center()
	_owner.summon_entity(Entity.EntityType.TREX, spawn_loc, {})
#endregion


#region ============================== SPAWN ==============================
func _spawn_n_chickens(chicken_number: int) -> void:
	for i in chicken_number:
		_spawn_chicken(_get_random_chicken_type())


func _get_random_chicken_type() -> Chicken.Type:
	if Utils.is_randomize_modifier_active(_gifted_chance, _owner.battle_id):
		var chicken_type = Utils.pick_random(_gifted_types, _owner.battle_id)
		return chicken_type if chicken_type != null else Chicken.Type.BASIC
	return Chicken.Type.BASIC


func _spawn_chicken(chicken_type: Chicken.Type, can_have_twin: bool = true) -> void:
	if can_have_twin and Utils.is_randomize_modifier_active(_twins_chance, _owner.battle_id):
			_spawn_chicken(_get_random_chicken_type(), false)
	
	var spawn_location_config := SpawnLocationConfig.create_random_arena()
	match chicken_type:
		Chicken.Type.BASIC:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config,{})
		Chicken.Type.GIFTED_ATTACK:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_ATTACK,
				"ad": _owner.stats.attack_damage * GIFTED_AD_RATIOS[_families_level[Family.Type.WARRIOR] - 1],
				"as": _owner.stats.attack_speed * GIFTED_AS_RATIOS[_families_level[Family.Type.WARRIOR] - 1],
				})
		Chicken.Type.GIFTED_POISON:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_POISON,
				"ratio": GIFTED_POISON_RATIO[_families_level[Family.Type.POISON] - 1],
				"number": GIFTED_POISON_STACKS[_families_level[Family.Type.POISON] - 1]
				})
		Chicken.Type.GIFTED_COLOSSUS:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_COLOSSUS,
				"hpmax": _owner.stats.health_max * GIFTED_COLOSSUS_HPMAX_RATIOS[_families_level[Family.Type.COLOSSUS] - 1]
			})
		Chicken.Type.GIFTED_LIGHT:
			var bonus_heal: float = _owner.stats.get_stat(EntityStats.StatType.STRENGTH, Utils.ActionType.UTILITY_HEAL)
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_LIGHT,
				"ratio_regen": GIFTED_LIGHT_REGEN_RATIOS[_families_level[Family.Type.LIGHT] - 1],
				"inherited_heal_ratio": bonus_heal * GIFTED_LIGHT_INHERITED_HEAL[_families_level[Family.Type.LIGHT] - 1]
			})
		Chicken.Type.GIFTED_ENGINEER:
			var bonus_shield: float = _owner.stats.get_stat(EntityStats.StatType.STRENGTH, Utils.ActionType.STACK_SHIELD)
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
				"Type": Chicken.Type.GIFTED_ENGINEER,
				"shield_per_attack": GIFTED_SHIELD_PER_ATTACK[_families_level[Family.Type.ENGINEER] - 1],
				"bonus_spawn": GIFTED_SHIELD_BONUS_SPAWN[_families_level[Family.Type.ENGINEER] - 1],
				"shield_strength_inherited": bonus_shield * GIFTED_SHIELD_INHERITED_SHIELD[_families_level[Family.Type.ENGINEER] - 1]
			})
		Chicken.Type.GIFTED_ARDENT_CELESTIAL:
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
					"Type": Chicken.Type.GIFTED_ARDENT_CELESTIAL,
					"ignite_stacks": GIFTED_ARDENT_CELESTIAL_IGNITE_STACKS[_families_level[Family.Type.ARDENT_CELESTIAL] - 1]
			})
		Chicken.Type.GIFTED_STORM_CALLER:
			var crit_chance: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_CHANCE, Utils.ActionType.DAMAGE_PHYSICAL)
			var crit_mult: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_MULT, Utils.ActionType.DAMAGE_PHYSICAL)
			_owner.summon_entity(Entity.EntityType.CHICKEN, spawn_location_config, {
					"Type": Chicken.Type.GIFTED_STORM_CALLER,
					"crit_chance": crit_chance * GIFTED_STORM_CALLER_CRIT_CHANCE_RATIO[_families_level[Family.Type.STORM_CALLER] - 1],
					"crit_mult": crit_mult * GIFTED_STORM_CALLER_CRIT_MULT_RATIO[_families_level[Family.Type.STORM_CALLER] - 1]
			})
#endregion


#region ============================== Callback ==============================
func _on_owner_target_module_new_entity_detected(entity: Entity) -> void:
	if not is_instance_valid(entity):
		Verbose.error("_on_owner_target_module_new_entity_detected() -> Bad entity", Verbose.Category.FAMILY_MANAGER)
		return
	
	if entity.team == _owner.team and entity is Chicken:
		_on_chicken_spawned(entity)


func _on_chicken_spawned(chicken: Chicken) -> void:
	_alive_chicken_count += 1
	_alive_ally_chickens.append(chicken)
	chicken.died.connect(_on_chicken_death.bind(chicken), CONNECT_ONE_SHOT)
	
	for cb: Callable in _chicken_lord_stats.on_chicken_spawned_callbacks:
		if cb.is_valid():
			cb.call({
				FamilyChickenLordStats.CbVars.ALIVE_CHICKENS: _alive_ally_chickens,
				FamilyChickenLordStats.CbVars.SELF_CHICKEN: chicken
			})


func _on_chicken_death(chicken: Chicken) -> void:
	_dead_chicken_count -= 1
	_alive_chicken_count += 1
	_alive_ally_chickens.erase(chicken)
	
	for cb: Callable in _chicken_lord_stats.on_chicken_death_callbacks:
		if cb.is_valid():
			cb.call({
				FamilyChickenLordStats.CbVars.ALIVE_CHICKENS: _alive_ally_chickens,
				FamilyChickenLordStats.CbVars.SELF_CHICKEN: chicken
			})
#endregion
