class_name CharacterStats
extends Resource

# ============================== Base stats ==============================

signal health_max_changed(new_health_max: int)
var _health_max: int # Maximum health of the character (Can't be heal over this)
@export var health_max: int:
	get: return _health_max
	set(value):
		_health_max = value
		health_max_changed.emit(_health_max)

signal health_changed(new_health: int)
var _health: int # Current health
var health: int:
	get: return _health
	set(value):
		_health = value
		health_changed.emit(_health)

signal mana_max_changed(new_mana_max: int)
var _mana_max: int # When mana hit mana_max, the ultimate is triggered
@export var mana_max: int:
	get: return _mana_max
	set(value):
		_mana_max = value
		mana_max_changed.emit(_mana_max)

signal mana_changed(new_mana: int)
var _mana: float # Current mana
var mana: float:
	get: return _mana
	set(value):
		_mana = value
		mana_changed.emit(_mana)

signal mana_regen_changed(new_mana_regen: float)
var _mana_regen: float # mana/s
@export var mana_regen: float:
	get: return _mana_regen
	set(value):
		_mana_regen = value
		mana_regen_changed.emit(_mana_regen)

signal attack_damage_changed(new_attack_damage: int)
var _attack_damage: int # Damage of auto attack
@export var attack_damage: int:
	get: return _attack_damage
	set(value):
		_attack_damage = value
		attack_damage_changed.emit(_attack_damage)

signal attack_speed_changed(new_attack_speed: float)
var _attack_speed: float # Attack per second
@export var attack_speed: float:
	get: return _attack_speed
	set(value):
		_attack_speed = value
		attack_speed_changed.emit(_attack_speed)

signal attack_move_speed_changed(new_attack_move_speed: float)
var _attack_move_speed: float # Move speed of the auto-attack projectile
@export var attack_move_speed: float:
	get: return _attack_move_speed
	set(value):
		_attack_move_speed = value
		attack_move_speed_changed.emit(_attack_move_speed)

signal physical_critical_chance_changed(new_physical_critical_chance: float)
var _physical_critical_chance: float # % of chance for an auto attack to do critical damage
@export var physical_critical_chance: float:
	get: return _physical_critical_chance
	set(value):
		_physical_critical_chance = value
		physical_critical_chance_changed.emit(_physical_critical_chance)

signal physical_critical_multiplier_changed(new_physical_critical_multiplier: float)
var _physical_critical_multiplier: float # Critical damage multiplier (2 per default)
@export var physical_critical_multiplier: float:
	get: return _physical_critical_multiplier
	set(value):
		_physical_critical_multiplier = value
		physical_critical_multiplier_changed.emit(_physical_critical_multiplier)

# ============================== Families stats ==============================

var auto_attack: CharacterAutoAttackStats
var defense: CharacterDefenseStats
var fire: CharacterFireStats
var storm: CharacterStormStats
var heal: CharacterHealStats
var life: CharacterLifeStats
var poison: CharacterPoisonStats

# ============================== Public function ==============================

func _init() -> void:
	auto_attack = CharacterAutoAttackStats.new()
	defense =  CharacterDefenseStats.new()
	fire = CharacterFireStats.new()
	storm = CharacterStormStats.new()
	heal = CharacterHealStats.new()
	life = CharacterLifeStats.new()
	poison = CharacterPoisonStats.new()


func reset_stats(default_stats: CharacterStats) -> void:
	health_max = default_stats.health_max
	health = default_stats.health_max
	mana_max = default_stats.mana_max
	mana = 0
	mana_regen= default_stats.mana_regen
	attack_damage = default_stats.attack_damage
	attack_speed = default_stats.attack_speed
	attack_move_speed = default_stats.attack_move_speed
	physical_critical_chance = default_stats.physical_critical_chance
	physical_critical_multiplier = default_stats.physical_critical_multiplier
