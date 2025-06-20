class_name EntityStats
extends Node

# ============================== Health ==============================

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
		if value == _health: return
		_health = value
		health_changed.emit(_health)

# ============================== Mana ==============================

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

# ============================== Auto-Attack ==============================

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

# ============================== Critic ==============================

signal physical_critical_chance_changed(new_physical_critical_chance: float)
var _physical_critical_chance: float # % of chance for an auto attack to do critical damage
@export var physical_critical_chance: float:
	get: return _physical_critical_chance
	set(value):
		if value == _physical_critical_chance: return
		_physical_critical_chance = value
		physical_critical_chance_changed.emit(_physical_critical_chance)

signal physical_critical_multiplier_changed(new_physical_critical_multiplier: float)
var _physical_critical_multiplier: float # Critical damage multiplier (2 per default)
@export var physical_critical_multiplier: float:
	get: return _physical_critical_multiplier
	set(value):
		if value == _physical_critical_multiplier: return
		_physical_critical_multiplier = value
		physical_critical_multiplier_changed.emit(_physical_critical_multiplier)

# ============================== Conditions ==============================

signal poison_stacks_changed(new_poison_stacks: int)
var _poison_stacks: int = 0
var poison_stacks: int:
	get: return _poison_stacks
	set(value):
		if value == _poison_stacks: return
		_poison_stacks = value
		poison_stacks_changed.emit(_poison_stacks)


signal ignite_stacks_changed(new_ignite_stacks: int)
var _ignite_stacks: int
var ignite_stacks: int:
	get: return _ignite_stacks
	set(value):
		if value == _ignite_stacks: return
		if value < 0: value = 0
		_ignite_stacks = value
		ignite_stacks_changed.emit(_ignite_stacks)

 
signal armor_stacks_changed(new_armor_stacks: int)
var _armor_stacks: int = 0
var armor_stacks: int:
	get: return _armor_stacks
	set(value):
		if value == _armor_stacks: return
		_armor_stacks = value
		armor_stacks_changed.emit(_armor_stacks)


# ============================== Public functions ==============================

func reset_from_hero(hero: Hero) -> void:
	health_max = hero.stats.health_max
	health = health_max
	mana_max = hero.stats.mana_max
	mana = 0
	mana_regen = hero.stats.mana_regen
	attack_damage = hero.stats.attack_damage
	attack_speed = hero.stats.attack_speed
	physical_critical_chance = hero.stats.physical_critical_chance
	physical_critical_multiplier = hero.stats.physical_critical_multiplier




 
