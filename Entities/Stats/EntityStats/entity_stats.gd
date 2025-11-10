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

enum CritType {
	ALL,
	ALL_DAMAGE,
	PHYSICAL_DAMAGE,
	MAGICAL_DAMAGE,
	POISON_DAMAGE,
	HEAL,
	STUN,
	CLEANSE,
	PURIFY,
	ALL_STACK,
	ARMOR_STACK,
	IGNITE_STACK,
	POISON_STACK,
	REGEN_STACK,
	NECROSIS_STACK
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
signal critical_chance_changed(new_critical_chance: float, critical_type: CritType)
signal critical_multiplier_changed(new_critical_multiplier: float, critical_type: CritType) # in %
var _critical_chances: Dictionary[CritType, float] = {
	CritType.ALL: 0.0,
	CritType.ALL_DAMAGE: 0.0,
	CritType.PHYSICAL_DAMAGE: 0.0,
	CritType.MAGICAL_DAMAGE: 0.0,
	CritType.POISON_DAMAGE: 0.0,
	CritType.HEAL: 0.0,
	CritType.STUN: 0.0,
	CritType.CLEANSE: 0.0,
	CritType.PURIFY: 0.0,
	CritType.ALL_STACK: 0.0,
	CritType.ARMOR_STACK: 0.0,
	CritType.IGNITE_STACK: 0.0,
	CritType.POISON_STACK: 0.0,
	CritType.REGEN_STACK: 0.0,
	CritType.NECROSIS_STACK: 0.0
}

var _critical_multipliers: Dictionary[CritType, float] = {
	CritType.ALL: 0.0,
	CritType.ALL_DAMAGE: 0.0,
	CritType.PHYSICAL_DAMAGE: 100.0,
	CritType.MAGICAL_DAMAGE: 100.0,
	CritType.POISON_DAMAGE: 100.0,
	CritType.HEAL: 100.0,
	CritType.STUN: 100.0,
	CritType.CLEANSE: 100.0,
	CritType.PURIFY: 100.0,
	CritType.ALL_STACK: 0.0,
	CritType.ARMOR_STACK: 100.0,
	CritType.IGNITE_STACK: 100.0,
	CritType.POISON_STACK: 100.0,
	CritType.REGEN_STACK: 100.0,
	CritType.NECROSIS_STACK: 100.0
}

#region ===== ALL
@export var all_critical_chance: float:
	get: return _critical_chances[CritType.ALL]
	set(value):
		if value == _critical_chances[CritType.ALL]: return
		_critical_chances[CritType.ALL] = value
		critical_chance_changed.emit(_critical_chances[CritType.ALL], CritType.ALL)

@export var all_critical_multiplier: float:
	get: return _critical_multipliers[CritType.ALL]
	set(value):
		if value == _critical_multipliers[CritType.ALL]: return
		_critical_multipliers[CritType.ALL] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.ALL], CritType.ALL)
#endregion

#region ========== DAMAGE
#region ===== ALL_DAMAGE
@export var all_damage_critical_chance: float:
	get: return _critical_chances[CritType.ALL_DAMAGE]
	set(value):
		if value == _critical_chances[CritType.ALL_DAMAGE]: return
		_critical_chances[CritType.ALL_DAMAGE] = value
		critical_chance_changed.emit(_critical_chances[CritType.ALL_DAMAGE], CritType.ALL_DAMAGE)

@export var all_damage_critical_multiplier: float:
	get: return _critical_multipliers[CritType.ALL_DAMAGE]
	set(value):
		if value == _critical_multipliers[CritType.ALL_DAMAGE]: return
		_critical_multipliers[CritType.ALL_DAMAGE] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.ALL_DAMAGE], CritType.ALL_DAMAGE)
#endregion

#region ===== PHYSICAL
@export var physical_critical_chance: float:
	get: return _critical_chances[CritType.PHYSICAL_DAMAGE]
	set(value):
		if value == _critical_chances[CritType.PHYSICAL_DAMAGE]: return
		_critical_chances[CritType.PHYSICAL_DAMAGE] = value
		critical_chance_changed.emit(_critical_chances[CritType.PHYSICAL_DAMAGE], CritType.PHYSICAL_DAMAGE)

@export var physical_critical_multiplier: float:
	get: return _critical_multipliers[CritType.PHYSICAL_DAMAGE]
	set(value):
		if value == _critical_multipliers[CritType.PHYSICAL_DAMAGE]: return
		_critical_multipliers[CritType.PHYSICAL_DAMAGE] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.PHYSICAL_DAMAGE], CritType.PHYSICAL_DAMAGE)
#endregion

#region ===== MAGICAL
@export var magical_critical_chance: float:
	get: return _critical_chances[CritType.MAGICAL_DAMAGE]
	set(value):
		if value == _critical_chances[CritType.MAGICAL_DAMAGE]: return
		_critical_chances[CritType.MAGICAL_DAMAGE] = value
		critical_chance_changed.emit(_critical_chances[CritType.MAGICAL_DAMAGE], CritType.MAGICAL_DAMAGE)

@export var magical_critical_multiplier: float:
	get: return _critical_multipliers[CritType.MAGICAL_DAMAGE]
	set(value):
		if value == _critical_multipliers[CritType.MAGICAL_DAMAGE]: return
		_critical_multipliers[CritType.MAGICAL_DAMAGE] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.MAGICAL_DAMAGE], CritType.MAGICAL_DAMAGE)
#endregion

#region ===== POISON_DAMAGE
@export var poison_critical_chance: float:
	get: return _critical_chances[CritType.POISON_DAMAGE]
	set(value):
		if value == _critical_chances[CritType.POISON_DAMAGE]: return
		_critical_chances[CritType.POISON_DAMAGE] = value
		critical_chance_changed.emit(_critical_chances[CritType.POISON_DAMAGE], CritType.POISON_DAMAGE)

@export var poison_critical_multiplier: float:
	get: return _critical_multipliers[CritType.POISON_DAMAGE]
	set(value):
		if value == _critical_multipliers[CritType.POISON_DAMAGE]: return
		_critical_multipliers[CritType.POISON_DAMAGE] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.POISON_DAMAGE], CritType.POISON_DAMAGE)
#endregion
#endregion

#region ========== UTILITY
#region ===== HEAL
@export var heal_critical_chance: float:
	get: return _critical_chances[CritType.HEAL]
	set(value):
		if value == _critical_chances[CritType.HEAL]: return
		_critical_chances[CritType.HEAL] = value
		critical_chance_changed.emit(_critical_chances[CritType.HEAL], CritType.HEAL)

@export var heal_critical_multiplier: float:
	get: return _critical_multipliers[CritType.HEAL]
	set(value):
		if value == _critical_multipliers[CritType.HEAL]: return
		_critical_multipliers[CritType.HEAL] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.HEAL], CritType.HEAL)
#endregion

#region ===== STUN
@export var stun_critical_chance: float:
	get: return _critical_chances[CritType.STUN]
	set(value):
		if value == _critical_chances[CritType.STUN]: return
		_critical_chances[CritType.STUN] = value
		critical_chance_changed.emit(_critical_chances[CritType.STUN], CritType.STUN)

@export var stun_critical_multiplier: float:
	get: return _critical_multipliers[CritType.STUN]
	set(value):
		if value == _critical_multipliers[CritType.STUN]: return
		_critical_multipliers[CritType.STUN] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.STUN], CritType.STUN)
#endregion

#region ===== CLEANSE
@export var cleanse_critical_chance: float:
	get: return _critical_chances[CritType.CLEANSE]
	set(value):
		if value == _critical_chances[CritType.CLEANSE]: return
		_critical_chances[CritType.CLEANSE] = value
		critical_chance_changed.emit(_critical_chances[CritType.CLEANSE], CritType.CLEANSE)

@export var cleanse_critical_multiplier: float:
	get: return _critical_multipliers[CritType.CLEANSE]
	set(value):
		if value == _critical_multipliers[CritType.CLEANSE]: return
		_critical_multipliers[CritType.CLEANSE] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.CLEANSE], CritType.CLEANSE)
#endregion

#region ===== PURIFY
@export var purify_critical_chance: float:
	get: return _critical_chances[CritType.PURIFY]
	set(value):
		if value == _critical_chances[CritType.PURIFY]: return
		_critical_chances[CritType.PURIFY] = value
		critical_chance_changed.emit(_critical_chances[CritType.PURIFY], CritType.PURIFY)

@export var purify_critical_multiplier: float:
	get: return _critical_multipliers[CritType.PURIFY]
	set(value):
		if value == _critical_multipliers[CritType.PURIFY]: return
		_critical_multipliers[CritType.PURIFY] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.PURIFY], CritType.PURIFY)
#endregion
#endregion

#region ========== CONDITION STACKS
#region ===== ALL_STACK
@export var all_stack_critical_chance: float:
	get: return _critical_chances[CritType.ALL_STACK]
	set(value):
		if value == _critical_chances[CritType.ALL_STACK]: return
		_critical_chances[CritType.ALL_STACK] = value
		critical_chance_changed.emit(_critical_chances[CritType.ALL_STACK], CritType.ALL_STACK)

@export var all_stack_critical_multiplier: float:
	get: return _critical_multipliers[CritType.ALL_STACK]
	set(value):
		if value == _critical_multipliers[CritType.ALL_STACK]: return
		_critical_multipliers[CritType.ALL_STACK] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.ALL_STACK], CritType.ALL_STACK)
#endregion

#region ===== ARMOR_STACK
@export var armor_stack_critical_chance: float:
	get: return _critical_chances[CritType.ARMOR_STACK]
	set(value):
		if value == _critical_chances[CritType.ARMOR_STACK]: return
		_critical_chances[CritType.ARMOR_STACK] = value
		critical_chance_changed.emit(_critical_chances[CritType.ARMOR_STACK], CritType.ARMOR_STACK)

@export var armor_stack_critical_multiplier: float:
	get: return _critical_multipliers[CritType.ARMOR_STACK]
	set(value):
		if value == _critical_multipliers[CritType.ARMOR_STACK]: return
		_critical_multipliers[CritType.ARMOR_STACK] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.ARMOR_STACK], CritType.ARMOR_STACK)
#endregion

#region ===== IGNITE_STACK
@export var ignite_stack_critical_chance: float:
	get: return _critical_chances[CritType.IGNITE_STACK]
	set(value):
		if value == _critical_chances[CritType.IGNITE_STACK]: return
		_critical_chances[CritType.IGNITE_STACK] = value
		critical_chance_changed.emit(_critical_chances[CritType.IGNITE_STACK], CritType.IGNITE_STACK)

@export var ignite_stack_critical_multiplier: float:
	get: return _critical_multipliers[CritType.IGNITE_STACK]
	set(value):
		if value == _critical_multipliers[CritType.IGNITE_STACK]: return
		_critical_multipliers[CritType.IGNITE_STACK] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.IGNITE_STACK], CritType.IGNITE_STACK)
#endregion

#region ===== POISON_STACK
@export var poison_stack_critical_chance: float:
	get: return _critical_chances[CritType.POISON_STACK]
	set(value):
		if value == _critical_chances[CritType.POISON_STACK]: return
		_critical_chances[CritType.POISON_STACK] = value
		critical_chance_changed.emit(_critical_chances[CritType.POISON_STACK], CritType.POISON_STACK)

@export var poison_stack_critical_multiplier: float:
	get: return _critical_multipliers[CritType.POISON_STACK]
	set(value):
		if value == _critical_multipliers[CritType.POISON_STACK]: return
		_critical_multipliers[CritType.POISON_STACK] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.POISON_STACK], CritType.POISON_STACK)
#endregion

#region ===== REGEN_STACK
@export var regen_stack_critical_chance: float:
	get: return _critical_chances[CritType.REGEN_STACK]
	set(value):
		if value == _critical_chances[CritType.REGEN_STACK]: return
		_critical_chances[CritType.REGEN_STACK] = value
		critical_chance_changed.emit(_critical_chances[CritType.REGEN_STACK], CritType.REGEN_STACK)

@export var regen_stack_critical_multiplier: float:
	get: return _critical_multipliers[CritType.REGEN_STACK]
	set(value):
		if value == _critical_multipliers[CritType.REGEN_STACK]: return
		_critical_multipliers[CritType.REGEN_STACK] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.REGEN_STACK], CritType.REGEN_STACK)
#endregion

#region ===== NECROSIS_STACK
@export var necrosis_stack_critical_chance: float:
	get: return _critical_chances[CritType.NECROSIS_STACK]
	set(value):
		if value == _critical_chances[CritType.NECROSIS_STACK]: return
		_critical_chances[CritType.NECROSIS_STACK] = value
		critical_chance_changed.emit(_critical_chances[CritType.NECROSIS_STACK], CritType.NECROSIS_STACK)

@export var necrosis_stack_critical_multiplier: float:
	get: return _critical_multipliers[CritType.NECROSIS_STACK]
	set(value):
		if value == _critical_multipliers[CritType.NECROSIS_STACK]: return
		_critical_multipliers[CritType.NECROSIS_STACK] = value
		critical_multiplier_changed.emit(_critical_multipliers[CritType.NECROSIS_STACK], CritType.NECROSIS_STACK)
#endregion
#endregion
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
	physical_critical_chance = hero.stats[lvl].physical_critical_chance
	physical_critical_multiplier = hero.stats[lvl].physical_critical_multiplier
	has_been_reset.emit()


func get_stat(stat_type: StatType, crit_type: CritType = CritType.PHYSICAL_DAMAGE) -> float:
	match stat_type:
		EntityStats.StatType.HEALTH_MAX: return float(_health_max)
		EntityStats.StatType.HEALTH: return float(_health)
		EntityStats.StatType.MANA_MAX: return float(_mana_max)
		EntityStats.StatType.MANA: return _mana
		EntityStats.StatType.MANA_REGEN: return _mana_regen
		EntityStats.StatType.AD: return float(_attack_damage)
		EntityStats.StatType.AA_SPEED: return _attack_speed
		EntityStats.StatType.CRIT_CHANCE: return _critical_chances.get(crit_type, 0.0)
		EntityStats.StatType.CRIT_MULT: return _critical_multipliers.get(crit_type, 0.0)
		EntityStats.StatType.PHYSICAL_RESISTANCE: return _physical_resistance
		EntityStats.StatType.MAGICAL_RESISTANCE: return _magical_resistance
		EntityStats.StatType.POISON_RESISTANCE: return _poison_resistance
		EntityStats.StatType.ALL_RESISTANCE: return _all_resistance
		_:
			printerr("EntityStats: get_stat() - Unknown stat type [", stat_type, "]")
			return 0.0


func update_stat(stat_type: StatType, value: float, crit_type: CritType = CritType.PHYSICAL_DAMAGE) -> void:
	match stat_type:
		EntityStats.StatType.HEALTH_MAX: health_max = int(round(value))
		EntityStats.StatType.HEALTH: health = int(round(value))
		EntityStats.StatType.MANA_MAX: mana_max = int(round(value))
		EntityStats.StatType.MANA: mana = value
		EntityStats.StatType.MANA_REGEN: mana_regen = value
		EntityStats.StatType.AD: attack_damage = int(round(value))
		EntityStats.StatType.AA_SPEED: attack_speed = value
		EntityStats.StatType.CRIT_CHANCE:
			match crit_type:
				CritType.ALL: all_critical_chance = value
				CritType.ALL_DAMAGE: all_damage_critical_chance = value
				CritType.PHYSICAL_DAMAGE: physical_critical_chance = value
				CritType.MAGICAL_DAMAGE: magical_critical_chance = value
				CritType.POISON_DAMAGE: poison_critical_chance = value
				CritType.HEAL: heal_critical_chance = value
				CritType.STUN: stun_critical_chance = value
				CritType.CLEANSE: cleanse_critical_chance = value
				CritType.PURIFY: purify_critical_chance = value
				CritType.ALL_STACK: all_stack_critical_chance = value
				CritType.ARMOR_STACK: armor_stack_critical_chance = value
				CritType.IGNITE_STACK: ignite_stack_critical_chance = value
				CritType.POISON_STACK: poison_stack_critical_chance = value
				CritType.REGEN_STACK: regen_stack_critical_chance = value
				CritType.NECROSIS_STACK: necrosis_stack_critical_chance = value
		EntityStats.StatType.CRIT_MULT:
			match crit_type:
				CritType.ALL: all_critical_multiplier = value
				CritType.ALL_DAMAGE: all_damage_critical_multiplier = value
				CritType.PHYSICAL_DAMAGE: physical_critical_multiplier = value
				CritType.MAGICAL_DAMAGE: magical_critical_multiplier = value
				CritType.POISON_DAMAGE: poison_critical_multiplier = value
				CritType.HEAL: heal_critical_multiplier = value
				CritType.STUN: stun_critical_multiplier = value
				CritType.CLEANSE: cleanse_critical_multiplier = value
				CritType.PURIFY: purify_critical_multiplier = value
				CritType.ALL_STACK: all_stack_critical_multiplier = value
				CritType.ARMOR_STACK: armor_stack_critical_multiplier = value
				CritType.IGNITE_STACK: ignite_stack_critical_multiplier = value
				CritType.POISON_STACK: poison_stack_critical_multiplier = value
				CritType.REGEN_STACK: regen_stack_critical_multiplier = value
				CritType.NECROSIS_STACK: necrosis_stack_critical_multiplier = value
		EntityStats.StatType.PHYSICAL_RESISTANCE: _physical_resistance = value
		EntityStats.StatType.MAGICAL_RESISTANCE: _magical_resistance = value
		EntityStats.StatType.POISON_RESISTANCE: _poison_resistance = value
		EntityStats.StatType.ALL_RESISTANCE: _all_resistance = value
		_: printerr("EntityStats: get_stat() - Unknown stat type [", stat_type, "]")
#endregion
