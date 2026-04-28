class_name ChickenLordManager
extends FamilyManager

# ============================== Constants ==============================
const FAMILY_NAME: StringName = &"ChickenLord"
const ANCESTRAL_GAUGE_NAME: StringName = &"Ancestral Gauge"

const TICKS_PER_SECOND: int = 60

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GIFTED_CHANCES: Array[float] = [0, 25.0, 35.0, 45.0, 55.0]

const P_PERIODIC_SPAWN_PERIODS: Array[float] = [12.0, 9.0, 8.0, 7.5, 7.0]
const P_PERIODIC_SPAWN_CHICKEN_NUMBERS: Array[int] = [0, 1, 1, 1, 1]
const P_START_CHICKENS: Array[int] = [0, 2, 3, 4, 6]

const EGG_HATCH_TIME: float = 3.0

# Chicken gifted attack stats
const GIFTED_AD_RATIOS: Array[float] = [0.15, 0.20, 0.25, 0.3]
const GIFTED_AS_RATIOS: Array[float] = [0.15, 0.20, 0.25, 0.3]

# Chicken gifted poison stats
const GIFTED_POISON_RATIO: Array[float] = [0.10, 0.15, 0.20, 0.25]
const GIFTED_POISON_STACKS: Array[int] = [1, 1, 2, 2]

# Chicken gifted colossus stats
const GIFTED_COLOSSUS_HPMAX_RATIOS: Array[float] = [1.0, 2.0, 3.0, 4.0]

# Chicken gifted light stats
const GIFTED_LIGHT_REGEN_RATIOS: Array[float] = [0.04, 0.06, 0.08, 0.10]
const GIFTED_LIGHT_INHERITED_HEAL: Array[float] = [0.3, 0.5, 0.7, 1.0]

# Chicken gifted shield stats
const GIFTED_SHIELD_BONUS_SPAWN: Array[int] = [50, 70, 90, 110]
const GIFTED_SHIELD_PER_ATTACK: Array[int] = [15, 25, 35, 50]
const GIFTED_SHIELD_INHERITED_SHIELD: Array[float] = [0.4, 0.6, 0.8, 1.0]

# Chicken gifted ardent celestial stats
const GIFTED_ARDENT_CELESTIAL_IGNITE_STACKS: Array[int] = [15, 25, 35, 50]

# Chicken gifted storm caller stats
const GIFTED_STORM_CALLER_CRIT_CHANCE_RATIO: Array[float] = [0.30, 0.40, 0.50, 0.60]
const GIFTED_STORM_CALLER_CRIT_MULT_RATIO: Array[float] = [0.30, 0.40, 0.50, 0.60]

# To roll the type of Chicken Gifted
const GIFTED_FAMILY_WEIGHTS: Array[float] = [0, 1, 4, 9, 16]

# TREX
const ANCESTRAL_GAUCHE_THRESHOLD: float = 100
const ANCESTRAL_GAUCHE_FILL_CHICKEN_SPAWN: float = 1
const ANCESTRAL_GAUCHE_FILL_GIFTED_CHICKEN_SPAWN: float = 2
const ANCESTRAL_GAUCHE_FILL_CHICKEN_DIE: float = 1
const ANCESTRAL_GAUCHE_FILL_CHICKEN_KILL: float = 3
const ANCESTRAL_GAUCHE_FILL_CHICKEN_QUEST: float = 50
const ANCESTRAL_GAUCHE_FILL_CHICKEN_ALIVE_END_OF_FIGHT: float = 0.5
const ANCESTRAL_GAUCHE_FILL_CHICKEN_LORD_FAMILY_LEVELS: Array[float] = [0, 10, 20, 30, 40]

const TREX_TIMER_BASE: float = 20 # Time in seconds before the TRex spawn
const TREX_TIMER_REDUCTION: Array[float] = [0, 0.3, 0.5, 0.7, 1.0]
const TREX_HP_GAIN: int = 500
const TREX_PRIMAL_SHAKE_PERIOD: Array[float] = [5, 5, 5]

#region ============================== Private variables ==============================
var _chicken_lord_stats: FamilyChickenLordStats
var _gifted_chance: float
var _families_level: Dictionary[Family.Type, int]
var _alive_ally_chickens: Array[Chicken]

var _trex_gauge: float
#endregion

#region ============================== Node base function ==============================
func _ready() -> void:
	_chicken_lord_stats = _owner.families_stats.chicken_lord
#endregion

#region ============================== public API ==============================
func start() -> void:
	_families_level = _owner.get_families_level()
	_init_gifted_types()
	_trex_gauge = _owner.data_memory.get_data(FAMILY_NAME, ANCESTRAL_GAUGE_NAME, 0)

	_gifted_chance = GIFTED_CHANCES[level] + _chicken_lord_stats.gifted_chance_increase
	if level >= 1:
		_start_passive()

	_owner.target.new_entity_detected.connect(_on_owner_target_module_new_entity_detected)

	for entity in _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if entity is Chicken and entity.team == _owner.team:
			_on_chicken_spawned(entity)


func stop() -> void:
	pass
#endregion


func _init_gifted_types() -> void:
	for family_type in _families_level:
		for i in GIFTED_FAMILY_WEIGHTS[_families_level[family_type]]:
			match family_type:
				Family.Type.WARRIOR: _chicken_lord_stats.gifted_types.append(Chicken.Type.GIFTED_ATTACK)
				Family.Type.ARDENT_CELESTIAL: _chicken_lord_stats.gifted_types.append(Chicken.Type.GIFTED_ARDENT_CELESTIAL)
				Family.Type.ENGINEER: _chicken_lord_stats.gifted_types.append(Chicken.Type.GIFTED_ENGINEER)
				Family.Type.STORM_CALLER: _chicken_lord_stats.gifted_types.append(Chicken.Type.GIFTED_STORM_CALLER)
				Family.Type.LIGHT: _chicken_lord_stats.gifted_types.append(Chicken.Type.GIFTED_LIGHT)
				Family.Type.POISON: _chicken_lord_stats.gifted_types.append(Chicken.Type.GIFTED_POISON)
				Family.Type.COLOSSUS: _chicken_lord_stats.gifted_types.append(Chicken.Type.GIFTED_COLOSSUS)
				Family.Type.NECROSIS: _chicken_lord_stats.gifted_types.append(Chicken.Type.GIFTED_NECROSIS)


#region ============================== PASSIVE ==============================
func _start_passive() -> void:
	_register_egg_summon_modifier()
	_register_basic_chicken_stats_modifier()
	_register_gifted_chicken_stats_modifier()
	_battle_start_chicken_spawn()
	var spawn_period: float = P_PERIODIC_SPAWN_PERIODS[level] - _chicken_lord_stats.spawn_period_decrease
	var chicken_number: int = P_PERIODIC_SPAWN_CHICKEN_NUMBERS[level]
	_owner.periodic_timer_registry.register(&"Chicken passive", spawn_period, _spawn_n_chickens.bind(chicken_number), true)

	if _trex_gauge >= ANCESTRAL_GAUCHE_THRESHOLD:
		var spawn_loc := SpawnLocationConfig.create_arena_center()
		_owner.summon.summon_entity(Entity.EntityType.TREX, spawn_loc, {
			TRex.Modifier.PRIMAL_SHAKE_PERIOD: 8,
			TRex.Modifier.PRIMAL_SHAKE_NUMBER: 2,
			TRex.Modifier.HP_BONUS: 1000
		})
#endregion


#region ============================== MODIFIERS ==============================

## Registers a persistent SUMMON ActionModifier that intercepts ALL CHICKEN_EGG summons.
## Automatically injects base chicken stats, hatch_modifiers, and rolls gifted chance.
## This means any caller only needs to pass {HATCH_TIME: x} to spawn a fully-configured egg.
func _register_egg_summon_modifier() -> void:
	var modifier := ActionModifier.new()
	modifier.id = &"ChickenLord Egg"
	modifier.action_type = Utils.ActionCategory.SUMMON
	modifier.is_one_time_effect = false
	modifier.auto_cleanup = true
	modifier.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.ENTITY_TYPE) != Entity.EntityType.CHICKEN_EGG:
			return
		var em: Dictionary = cb_vars[ActionModifier.VarType.ENTITY_MODIFIER]
		
		# 1. Inject hatch_modifiers from family stats (twins, etc.)
		if not em.has(ChickenEgg.Modifier.HATCH_MODIFIERS):
			em[ChickenEgg.Modifier.HATCH_MODIFIERS] = [] as Array[HatchModifier]
		var hm: Array = em[ChickenEgg.Modifier.HATCH_MODIFIERS]
		for hatch_mod in _chicken_lord_stats.hatch_modifiers:
			hm.append(hatch_mod)
		
		# 2. Roll gifted (only if type is still BASIC — allows forced gifted from other callers)
		if em.get(ChickenEgg.Modifier.CHICKEN_TYPE, Chicken.Type.BASIC) != Chicken.Type.BASIC:
			return
		if not Utils.is_randomize_modifier_active(_gifted_chance, _owner.battle_id):
			return
		var chicken_type = Utils.pick_random(_chicken_lord_stats.gifted_types, _owner.battle_id)
		if chicken_type == null:
			return
		em[ChickenEgg.Modifier.CHICKEN_TYPE] = chicken_type
	_owner.action_modifiers_registry.register_modifier(modifier)


func _register_basic_chicken_stats_modifier() -> void:
	var modifier := ActionModifier.new()
	modifier.id = &"ChickenLord Basic Stats"
	modifier.action_type = Utils.ActionCategory.SUMMON
	modifier.is_one_time_effect = false
	modifier.auto_cleanup = true
	modifier.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.ENTITY_TYPE) != Entity.EntityType.CHICKEN:
			return
		var cm: Dictionary = cb_vars.get(ActionModifier.VarType.ENTITY_MODIFIER, {})
		cm[Chicken.BaseStatsModifier.HP] = _chicken_lord_stats.HP[level]
		cm[Chicken.BaseStatsModifier.AD] = _chicken_lord_stats.AD[level]
		cm[Chicken.BaseStatsModifier.ARMOR] = _chicken_lord_stats.ARMOR[level]
		cm[Chicken.BaseStatsModifier.CRIT_CHANCE] = _chicken_lord_stats.CRIT_CHANCE[level]
		cm[Chicken.BaseStatsModifier.CRIT_MULTI] = _chicken_lord_stats.CRIT_MULTI[level]
	_owner.action_modifiers_registry.register_modifier(modifier)


func _register_gifted_chicken_stats_modifier() -> void:
	var modifier := ActionModifier.new()
	modifier.id = &"ChickenLord Gifted Stats"
	modifier.action_type = Utils.ActionCategory.SUMMON
	modifier.is_one_time_effect = false
	modifier.auto_cleanup = true
	modifier.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.ENTITY_TYPE) != Entity.EntityType.CHICKEN:
			return
		var cm: Dictionary = cb_vars.get(ActionModifier.VarType.ENTITY_MODIFIER, {})
		var chicken_type: Chicken.Type = cm.get("Type", Chicken.Type.BASIC)
		match chicken_type:
			Chicken.Type.GIFTED_ATTACK:
				cm["ad"] = _owner.stats.attack_damage * GIFTED_AD_RATIOS[_families_level[Family.Type.WARRIOR] - 1]
				cm["as"] = _owner.stats.attack_speed * GIFTED_AS_RATIOS[_families_level[Family.Type.WARRIOR] - 1]
			Chicken.Type.GIFTED_POISON:
				cm["ratio"] = GIFTED_POISON_RATIO[_families_level[Family.Type.POISON] - 1]
				cm["number"] = GIFTED_POISON_STACKS[_families_level[Family.Type.POISON] - 1]
			Chicken.Type.GIFTED_COLOSSUS:
				cm["hpmax"] = _owner.stats.health_max * GIFTED_COLOSSUS_HPMAX_RATIOS[_families_level[Family.Type.COLOSSUS] - 1]
			Chicken.Type.GIFTED_LIGHT:
				var bonus_heal: float = _owner.stats.get_stat(EntityStats.StatType.POWER, Utils.ActionType.UTILITY_HEAL)
				cm["ratio_regen"] = GIFTED_LIGHT_REGEN_RATIOS[_families_level[Family.Type.LIGHT] - 1]
				cm["inherited_heal_ratio"] = bonus_heal * GIFTED_LIGHT_INHERITED_HEAL[_families_level[Family.Type.LIGHT] - 1]
			Chicken.Type.GIFTED_ENGINEER:
				var bonus_shield: float = _owner.stats.get_stat(EntityStats.StatType.POWER, Utils.ActionType.STACK_SHIELD)
				cm["shield_per_attack"] = GIFTED_SHIELD_PER_ATTACK[_families_level[Family.Type.ENGINEER] - 1]
				cm["bonus_spawn"] = GIFTED_SHIELD_BONUS_SPAWN[_families_level[Family.Type.ENGINEER] - 1]
				cm["shield_strength_inherited"] = bonus_shield * GIFTED_SHIELD_INHERITED_SHIELD[_families_level[Family.Type.ENGINEER] - 1]
			Chicken.Type.GIFTED_ARDENT_CELESTIAL:
				cm["ignite_stacks"] = GIFTED_ARDENT_CELESTIAL_IGNITE_STACKS[_families_level[Family.Type.ARDENT_CELESTIAL] - 1]
			Chicken.Type.GIFTED_STORM_CALLER:
				var crit_chance: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_CHANCE, Utils.ActionType.DAMAGE_PHYSICAL)
				var crit_mult: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_MULT, Utils.ActionType.DAMAGE_PHYSICAL)
				cm["crit_chance"] = crit_chance * GIFTED_STORM_CALLER_CRIT_CHANCE_RATIO[_families_level[Family.Type.STORM_CALLER] - 1]
				cm["crit_mult"] = crit_mult * GIFTED_STORM_CALLER_CRIT_MULT_RATIO[_families_level[Family.Type.STORM_CALLER] - 1]
	_owner.action_modifiers_registry.register_modifier(modifier)
#endregion


#region ============================== SPAWN ==============================
func _spawn_n_chickens(chicken_number: int) -> void:
	for i in chicken_number:
		_spawn_chicken()


## Spawns a minimal egg. The SUMMON ActionModifier injects base stats, hatch_modifiers, and gifted roll.
func _spawn_chicken() -> void:
	var spawn_location_config := SpawnLocationConfig.create_random_arena()
	_owner.summon.summon_entity(Entity.EntityType.CHICKEN_EGG, spawn_location_config, {
		ChickenEgg.Modifier.HATCH_TIME: EGG_HATCH_TIME,
	})


func _battle_start_chicken_spawn() -> void:
	if _chicken_lord_stats.spawn_trex_on_start:
		for i in P_START_CHICKENS[level]:
			var spawn_loc := SpawnLocationConfig.create_random_arena()
			_owner.summon.summon_entity(Entity.EntityType.TREX, spawn_loc, {
				TRex.Modifier.PRIMAL_SHAKE_PERIOD: 8,
				TRex.Modifier.PRIMAL_SHAKE_NUMBER: 2,
				TRex.Modifier.HP_BONUS: 1000
		})
	else:
		_spawn_n_chickens(P_START_CHICKENS[level] + _chicken_lord_stats.spawn_number_increase)
		
		
#endregion


#region ============================== Callback ==============================
func _on_owner_target_module_new_entity_detected(entity: Entity) -> void:
	if not is_instance_valid(entity):
		Verbose.error("_on_owner_target_module_new_entity_detected() -> Bad entity", Verbose.Category.FAMILY_MANAGER)
		return
	
	if entity.team == _owner.team and entity is Chicken:
		_on_chicken_spawned(entity)


func _on_chicken_spawned(chicken: Chicken) -> void:
	_chicken_lord_stats.alive_chicken_count += 1
	_alive_ally_chickens.append(chicken)
	chicken.died.connect(_on_chicken_death.bind(chicken), CONNECT_ONE_SHOT)
	
	if chicken is ChickenGifted:
		_owner.data_memory.increment_data(FAMILY_NAME, ANCESTRAL_GAUGE_NAME, ANCESTRAL_GAUCHE_FILL_GIFTED_CHICKEN_SPAWN)
	else:
		_owner.data_memory.increment_data(FAMILY_NAME, ANCESTRAL_GAUGE_NAME, ANCESTRAL_GAUCHE_FILL_CHICKEN_SPAWN)
	
	for cb: Callable in _chicken_lord_stats.on_chicken_spawned_callbacks:
		if cb.is_valid():
			cb.call({
				FamilyChickenLordStats.CbVars.ALIVE_CHICKENS: _alive_ally_chickens,
				FamilyChickenLordStats.CbVars.SELF_CHICKEN: chicken,
				FamilyChickenLordStats.CbVars.DEATH_COUNT: _chicken_lord_stats.dead_chicken_count
			})


func _on_chicken_death(chicken: Chicken) -> void:
	_chicken_lord_stats.dead_chicken_count += 1
	_chicken_lord_stats.alive_chicken_count -= 1
	_alive_ally_chickens.erase(chicken)
	
	for cb: Callable in _chicken_lord_stats.on_chicken_death_callbacks:
		if cb.is_valid():
			cb.call({
				FamilyChickenLordStats.CbVars.ALIVE_CHICKENS: _alive_ally_chickens,
				FamilyChickenLordStats.CbVars.SELF_CHICKEN: chicken,
				FamilyChickenLordStats.CbVars.DEATH_COUNT: _chicken_lord_stats.dead_chicken_count
			})
#endregion
