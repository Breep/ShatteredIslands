class_name EntityStats
extends Node

#region ============================== Enum ==============================

enum StatType {
	HEALTH_MAX,
	HEALTH,
	MANA_MAX,
	MANA,
	MANA_REGEN,
	AD,
	AA_SPEED,
	CRIT_CHANCE,
	CRIT_MULT,
	PHYSICAL_RESISTANCE,
	MAGICAL_RESISTANCE,
	POISON_RESISTANCE,
	ALL_RESISTANCE
}
#endregion

#region ============================== Signals ==============================
signal has_been_reset()
#endregion

#region ============================== Health ==============================
@export_group("Health")
signal health_max_changed(new_health_max: int)
var _health_max: int # Maximum health of the character (Can't be heal over this)
@export var health_max: int:
	get: return _health_max
	set(value):
		if value == _health_max: return
		_health_max = value
		health_max_changed.emit(_health_max)

signal health_changed(new_health: int)
var _health: int # Current health
var health: int:
	get: return _health
	set(value):
		value = clampi(value, 0, health_max)
		if value == _health: return
		_health = value
		health_changed.emit(_health)
#endregion

#region ============================== Mana ==============================
@export_group("Mana")
signal mana_max_changed(new_mana_max: int)
var _mana_max: int # When mana hit mana_max, the ultimate is triggered
@export var mana_max: int:
	get: return _mana_max
	set(value):
		if value == _mana_max: return
		_mana_max = value
		mana_max_changed.emit(_mana_max)

signal mana_changed(new_mana: int)
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
@export_group("Attack damage")
signal attack_damage_changed(new_attack_damage: int)
var _attack_damage: int # Damage of auto attack
@export var attack_damage: int:
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
var _critical_chances: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 0.0,
	Utils.ActionType.DAMAGE_MAGICAL: 0.0,
	Utils.ActionType.DAMAGE_POISON: 0.0,
	Utils.ActionType.UTILITY_HEAL: 0.0,
	Utils.ActionType.UTILITY_STUN: 0.0,
	Utils.ActionType.UTILITY_CLEANSE: 0.0,
	Utils.ActionType.UTILITY_PURIFY: 0.0,
	Utils.ActionType.STACK_ARMOR: 0.0,
	Utils.ActionType.STACK_IGNITE: 0.0,
	Utils.ActionType.STACK_POISON: 0.0,
	Utils.ActionType.STACK_REGEN: 0.0,
	Utils.ActionType.STACK_NECROSIS: 0.0,
}

var _critical_multipliers: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 100,
	Utils.ActionType.DAMAGE_MAGICAL: 100,
	Utils.ActionType.DAMAGE_POISON: 100,
	Utils.ActionType.UTILITY_HEAL: 100,
	Utils.ActionType.UTILITY_STUN: 100,
	Utils.ActionType.UTILITY_CLEANSE: 100,
	Utils.ActionType.UTILITY_PURIFY: 100,
	Utils.ActionType.STACK_ARMOR: 100,
	Utils.ActionType.STACK_IGNITE: 100,
	Utils.ActionType.STACK_POISON: 100,
	Utils.ActionType.STACK_REGEN: 100,
	Utils.ActionType.STACK_NECROSIS: 100,
}

const CRITICAL_MULTIPLIERS_DEFAULT: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 100,
	Utils.ActionType.DAMAGE_MAGICAL: 100,
	Utils.ActionType.DAMAGE_POISON: 100,
	Utils.ActionType.UTILITY_HEAL: 100,
	Utils.ActionType.UTILITY_STUN: 100,
	Utils.ActionType.UTILITY_CLEANSE: 100,
	Utils.ActionType.UTILITY_PURIFY: 100,
	Utils.ActionType.STACK_ARMOR: 100,
	Utils.ActionType.STACK_IGNITE: 100,
	Utils.ActionType.STACK_POISON: 100,
	Utils.ActionType.STACK_REGEN: 100,
	Utils.ActionType.STACK_NECROSIS: 100,
}
#endregion

#region ============================== Condition Stacks ==============================
@export_group("Condition Stacks")
signal poison_stacks_changed(new_poison_stacks: int)
var _poison_stacks: int = 0
@export var poison_stacks: int:
	get: return _poison_stacks
	set(value):
		if value < 0: value = 0
		if value == _poison_stacks: return
		_poison_stacks = max(0, value)
		poison_stacks_changed.emit(_poison_stacks)


signal ignite_stacks_changed(new_ignite_stacks: int)
var _ignite_stacks: int
@export var ignite_stacks: int:
	get: return _ignite_stacks
	set(value):
		if value < 0: value = 0
		if value == _ignite_stacks: return
		_ignite_stacks = max(0, value)
		ignite_stacks_changed.emit(_ignite_stacks)


signal armor_stacks_changed(new_armor_stacks: int)
var _armor_stacks: int = 0
@export var armor_stacks: int:
	get: return _armor_stacks
	set(value):
		if value == _armor_stacks: return
		_armor_stacks = max(0, value)
		armor_stacks_changed.emit(_armor_stacks)


signal regen_stacks_changed(new_regen_stacks: int)
var _regen_stacks: int = 0
@export var regen_stacks: int:
	get: return _regen_stacks
	set(value):
		if value == _regen_stacks: return
		_regen_stacks = max(0, value)
		regen_stacks_changed.emit(_regen_stacks)
#endregion

#region ============================== Resistances ==============================
@export_group("Resistances")
signal physical_resistance_changed(new_physical_resistance: int)
var _physical_resistance: float
@export var physical_resistance: float:
	get: return _physical_resistance
	set(value):
		if value == _physical_resistance: return
		_physical_resistance = value
		physical_resistance_changed.emit(_physical_resistance)

signal magical_resistance_changed(new_magical_resistance: float)
var _magical_resistance: float
@export var magical_resistance: float:
	get: return _magical_resistance
	set(value):
		if value == _magical_resistance: return
		_magical_resistance = value
		magical_resistance_changed.emit(_magical_resistance)

signal poison_resistance_changed(new_poison_resistance: float)
var _poison_resistance: float
@export var poison_resistance: float:
	get: return _poison_resistance
	set(value):
		if value == _poison_resistance: return
		_poison_resistance = value
		poison_resistance_changed.emit(_poison_resistance)

signal all_resistance_changed(new_all_resistance: float)
var _all_resistance: float
@export var all_resistance: float:
	get: return _all_resistance
	set(value):
		if value == _all_resistance: return
		_all_resistance = value
		all_resistance_changed.emit(_all_resistance)
#endregion

#region ============================== Public functions ==============================
func get_stacks_number() -> int:
	return _poison_stacks + _ignite_stacks + _armor_stacks

func reset_from_hero(hero: Hero, lvl: int) -> void:
	health_max = hero.stats[lvl].health_max
	health = health_max
	mana_max = hero.stats[lvl].mana_max
	mana = 0
	mana_regen = hero.stats[lvl].mana_regen
	attack_damage = hero.stats[lvl].attack_damage
	attack_speed = hero.stats[lvl].attack_speed
	
	for action_type: Utils.ActionType in _critical_chances.keys():
		_critical_chances[action_type] = hero.stats[lvl].critical_multiplier.get(action_type, CRITICAL_MULTIPLIERS_DEFAULT[action_type])
	
	has_been_reset.emit()


func get_stat(stat_type: StatType, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> float:
	match stat_type:
		EntityStats.StatType.HEALTH_MAX: return float(_health_max)
		EntityStats.StatType.HEALTH: return float(_health)
		EntityStats.StatType.MANA_MAX: return float(_mana_max)
		EntityStats.StatType.MANA: return _mana
		EntityStats.StatType.MANA_REGEN: return _mana_regen
		EntityStats.StatType.AD: return float(_attack_damage)
		EntityStats.StatType.AA_SPEED: return _attack_speed
		EntityStats.StatType.CRIT_CHANCE: return _critical_chances[action_type]
		EntityStats.StatType.CRIT_MULT: return _critical_multipliers[action_type]
		EntityStats.StatType.PHYSICAL_RESISTANCE: return _physical_resistance
		EntityStats.StatType.MAGICAL_RESISTANCE: return _magical_resistance
		EntityStats.StatType.POISON_RESISTANCE: return _poison_resistance
		EntityStats.StatType.ALL_RESISTANCE: return _all_resistance
		_:
			printerr("EntityStats: get_stat() - Unknown stat type [", stat_type, "]")
			return 0.0


func update_stat(stat_type: StatType, value: float, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> void:
	match stat_type:
		EntityStats.StatType.HEALTH_MAX: health_max = int(round(value))
		EntityStats.StatType.HEALTH: health = int(round(value))
		EntityStats.StatType.MANA_MAX: mana_max = int(round(value))
		EntityStats.StatType.MANA: mana = value
		EntityStats.StatType.MANA_REGEN: mana_regen = value
		EntityStats.StatType.AD: attack_damage = int(round(value))
		EntityStats.StatType.AA_SPEED: attack_speed = value
		EntityStats.StatType.CRIT_CHANCE:
			_critical_chances[action_type] = value
			critical_chance_changed.emit(value, action_type)
		EntityStats.StatType.CRIT_MULT:
			_critical_multipliers[action_type] = value
			critical_multiplier_changed.emit(value, action_type)
		EntityStats.StatType.PHYSICAL_RESISTANCE: _physical_resistance = value
		EntityStats.StatType.MAGICAL_RESISTANCE: _magical_resistance = value
		EntityStats.StatType.POISON_RESISTANCE: _poison_resistance = value
		EntityStats.StatType.ALL_RESISTANCE: _all_resistance = value
		_: printerr("EntityStats: get_stat() - Unknown stat type [", stat_type, "]")
#endregion
