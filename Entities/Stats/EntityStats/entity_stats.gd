class_name EntityStats
extends Resource

#region ============================== Enum ==============================
enum StatType {
	HEALTH_MAX,
	HEALTH,
	MANA_MAX,
	MANA,
	MANA_REGEN,
	AD,
	AA_SPEED,
	ATTACK_RANGE,
	CRIT_CHANCE,
	CRIT_CHANCE_GLOBAL,
	CRIT_MULT,
	CRIT_MULT_GLOBAL,
	RESISTANCE,
	VULNERABILITY,
	STRENGTH,
	WEAKNESS,
	DODGE,
	CRIT_RESISTANCE
	}
#endregion

#region ============================== Signals ==============================
signal has_been_reset()
#endregion

#region ============================== Health ==============================
@export_group("Health")
signal health_max_changed(new_health_max: float)
var _health_max: float = 100 # Maximum health of the entity (Can't be heal over this)
@export var health_max: float:
	get: return _health_max
	set(value):
		if value == _health_max: return
		_health_max = value
		health_max_changed.emit(_health_max)

signal health_changed(new_health: float)
var _health: float # Current health
var health: float:
	get: return _health
	set(value):
		value = clampf(value, 0, health_max)
		if value == _health: return
		_health = value
		health_changed.emit(_health)
#endregion

#region ============================== Mana ==============================
@export_group("Mana")
signal mana_max_changed(new_mana_max: float)
var _mana_max: float # When mana hit mana_max, the ultimate is triggered
@export var mana_max: float:
	get: return _mana_max
	set(value):
		if value == _mana_max: return
		_mana_max = value
		mana_max_changed.emit(_mana_max)

signal mana_changed(new_mana: float)
var _mana: float # Current mana
var mana: float:
	get: return _mana
	set(value):
		if value == _mana: return
		_mana = value
		mana_changed.emit(_mana)

signal mana_regen_changed(new_mana_regen: float)
var _mana_regen: float # mana/s
@export var mana_regen: float:
	get: return _mana_regen
	set(value):
		if value == _mana_regen: return
		_mana_regen = value
		mana_regen_changed.emit(_mana_regen)
#endregion

#region ============================== Auto-Attack ==============================
enum AutoAttackType {RANGED, MELEE}

@export_group("Attack")
@export var auto_attack_type: AutoAttackType = AutoAttackType.RANGED

signal attack_range_changed(new_attack_range: float)
var _attack_range: float = -1.0 # -1 = unlimited range (default)
@export var attack_range: float:
	get: return _attack_range
	set(value):
		if value == _attack_range: return
		_attack_range = value
		attack_range_changed.emit(_attack_range)

signal attack_damage_changed(new_attack_damage: float)
var _attack_damage: float # Damage of auto attack
@export var attack_damage: float:
	get: return _attack_damage
	set(value):
		if value == _attack_damage: return
		_attack_damage = value
		attack_damage_changed.emit(_attack_damage)

signal attack_speed_changed(new_attack_speed: float)
var _attack_speed: float # Attack per second
@export var attack_speed: float:
	get: return _attack_speed
	set(value):
		if value == _attack_speed: return
		_attack_speed = value
		attack_speed_changed.emit(_attack_speed)
#endregion

#region ============================== Critic ==============================
@export_group("Critic")
signal critical_chance_changed(new_critical_chance: float, critical_type: Utils.ActionType)
signal critical_multiplier_changed(new_critical_multiplier: float, critical_type: Utils.ActionType) # in %
@export var _critical_chances: Dictionary[Utils.ActionType, float]
@export var _critical_multipliers: Dictionary[Utils.ActionType, float]
#endregion


#region ============================== Resistances ==============================
@export_group("Resistance")
signal resistance_changed(new_resistance: float, action_type: Utils.ActionType)
@export var _resistances: Dictionary[Utils.ActionType, float]

signal crit_resistance_changed(new_crit_resistance: float, action_type: Utils.ActionType)
@export var _crit_resistances: Dictionary[Utils.ActionType, float]
#endregion

#region ============================== Dodge ==============================
@export_group("Dodge")
signal dodge_changed(new_dodge: float, action_type: Utils.ActionType)
@export var _dodges: Dictionary[Utils.ActionType, float]
#endregion

#region ============================== Vulnerability ==============================
@export_group("Vulnerability")
signal vulnerability_changed(new_vulnerability: float, action_type: Utils.ActionType)
@export var _vulnerabilities: Dictionary[Utils.ActionType, float]
#endregion

#region ============================== Strength ==============================
@export_group("Strength")
signal strength_changed(new_strength: float, action_type: Utils.ActionType)
@export var _strengths: Dictionary[Utils.ActionType, float]
#endregion

#region ============================== Weakness ==============================
@export_group("Weakness")
signal weakness_changed(new_weakness: float, action_type: Utils.ActionType)
@export var _weaknesses: Dictionary[Utils.ActionType, float]
#endregion

#region ============================== Public functions ==============================
func reset_from_hero_desc(hero: HeroDesc, lvl: int) -> EntityStats:
	if lvl < 1 or lvl > 10:
		Verbose.error("reset_from_hero_desc() - Invalid hero level [" + lvl + "]", Verbose.Category.ENTITY)
		return self
	
	health_max = hero.stats[lvl].health_max
	health = health_max
	mana_max = hero.stats[lvl].mana_max
	mana = 0
	mana_regen = hero.stats[lvl].mana_regen
	attack_damage = hero.stats[lvl].attack_damage
	attack_speed = hero.stats[lvl].attack_speed
	attack_range = hero.stats[lvl].attack_range
	auto_attack_type = hero.stats[lvl].auto_attack_type
	
	for action_type: Utils.ActionType in Utils.get_all_actions():
		_critical_chances[action_type] = hero.stats[lvl].critical_chances.get(action_type, 0.0)
		_critical_multipliers[action_type] = hero.stats[lvl].critical_multipliers.get(action_type, 100.0)
		_resistances[action_type] = hero.stats[lvl].resistances.get(action_type, 0.0)
		_vulnerabilities[action_type] = hero.stats[lvl].vulnerabilities.get(action_type, 0.0)
		_dodges[action_type] = hero.stats[lvl].dodges.get(action_type, 0.0)
		_strengths[action_type] = hero.stats[lvl].strength.get(action_type, 0.0)
		_weaknesses[action_type] = hero.stats[lvl].weakness.get(action_type, 0.0)
		_crit_resistances[action_type] = hero.stats[lvl].crit_resistances.get(action_type, 0.0)
	
	has_been_reset.emit()
	return self


func reset_from_self() -> EntityStats:
	if health == 0 and health_max > 0:
		health = health_max
	if mana == 0 and mana_max > 0:
		mana = 0
	return self


func get_stat(stat_type: StatType, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> float:
	match stat_type:
		EntityStats.StatType.HEALTH_MAX: return float(_health_max)
		EntityStats.StatType.HEALTH: return float(_health)
		EntityStats.StatType.MANA_MAX: return float(_mana_max)
		EntityStats.StatType.MANA: return _mana
		EntityStats.StatType.MANA_REGEN: return _mana_regen
		EntityStats.StatType.AD: return float(_attack_damage)
		EntityStats.StatType.AA_SPEED: return _attack_speed
		EntityStats.StatType.ATTACK_RANGE: return _attack_range
		EntityStats.StatType.CRIT_CHANCE: return _critical_chances.get(action_type, 0.0)
		EntityStats.StatType.CRIT_MULT: return _critical_multipliers.get(action_type, 100.0)
		EntityStats.StatType.RESISTANCE: return _resistances.get(action_type, 0.0)
		EntityStats.StatType.VULNERABILITY: return _vulnerabilities.get(action_type, 0.0)
		EntityStats.StatType.DODGE: return _dodges.get(action_type, 0.0)
		EntityStats.StatType.STRENGTH: return _strengths.get(action_type, 0.0)
		EntityStats.StatType.WEAKNESS: return _weaknesses.get(action_type, 0.0)
		EntityStats.StatType.CRIT_RESISTANCE: return _crit_resistances.get(action_type, 0.0)
		_:
			printerr("EntityStats: get_stat() - Unknown stat type [", stat_type, "]")
			return 0.0


func update_stat(stat_type: StatType, value: float, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> void:
	match stat_type:
		EntityStats.StatType.HEALTH_MAX: health_max = value
		EntityStats.StatType.HEALTH: health = value
		EntityStats.StatType.MANA_MAX: mana_max = value
		EntityStats.StatType.MANA: mana = value
		EntityStats.StatType.MANA_REGEN: mana_regen = value
		EntityStats.StatType.AD: attack_damage = value
		EntityStats.StatType.AA_SPEED: attack_speed = value
		EntityStats.StatType.ATTACK_RANGE: attack_range = value
		EntityStats.StatType.CRIT_CHANCE:
			_critical_chances[action_type] = value
			critical_chance_changed.emit(value, action_type)
		EntityStats.StatType.CRIT_MULT:
			_critical_multipliers[action_type] = value
			critical_multiplier_changed.emit(value, action_type)
		EntityStats.StatType.RESISTANCE:
			_resistances[action_type] = value
			resistance_changed.emit(value, action_type)
		EntityStats.StatType.VULNERABILITY:
			_vulnerabilities[action_type] = value
			vulnerability_changed.emit(value, action_type)
		EntityStats.StatType.DODGE:
			_dodges[action_type] = value
			dodge_changed.emit(value, action_type)
		EntityStats.StatType.STRENGTH:
			_strengths[action_type] = value
			strength_changed.emit(value, action_type)
		EntityStats.StatType.WEAKNESS:
			_weaknesses[action_type] = value
			weakness_changed.emit(value, action_type)
		EntityStats.StatType.CRIT_RESISTANCE:
			_crit_resistances[action_type] = value
			crit_resistance_changed.emit(value, action_type)
		_: printerr("EntityStats: get_stat() - Unknown stat type [", stat_type, "]")
#endregion
