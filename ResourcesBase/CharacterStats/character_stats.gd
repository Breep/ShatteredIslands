class_name CharacterStats
extends Resource

# ============================== Base stats ==============================

@export var health_max: int # Maximum health of the character (Can't be heal over this)
var health: int # Current health

@export var mana_max: int # When mana hit mana_max, the ultimate is triggered
var mana: float # Current mana
@export var mana_regen: float # mana/s

@export var energy_max: int # Déplacement max stockable (en m)
var energy: float # Current energy
@export var energy_regen: float # energy/s
@export var move_speed: float # m/s

@export var attack_damage: int # Damage of auto attack
@export var attack_speed: float # Attack per second
@export var attack_move_speed: float # Move speed of the auto-attack projectile

@export var physical_critical_chance: float # % of chance for an auto attack to do critical damage
@export var physical_critical_multiplier: float # Critical damage multiplier (2 per default)

# ============================== Families stats ==============================

var auto_attack: CharacterAutoAttackStats
var defense: CharacterDefenseStats
var fire: CharacterFireStats
var storm: CharacterStormStats
var heal: CharacterHealStats
var hp: CharacterLifeStats
var poison: CharacterPoisonStats
var shadow: CharacterShadowStats

# ============================== Public function ==============================

func init(hero_stats: CharacterStats) -> void:
	print("Character stats initialization")
	auto_attack = CharacterAutoAttackStats.new()
	defense =  CharacterDefenseStats.new()
	fire = CharacterFireStats.new()
	storm = CharacterStormStats.new()
	heal = CharacterHealStats.new()
	hp = CharacterLifeStats.new()
	poison = CharacterPoisonStats.new()
	shadow = CharacterShadowStats.new()
	_copy_stats(hero_stats)

func _copy_stats(hero_stats: CharacterStats) -> void:
	health_max = hero_stats.health_max
	health = health_max
	mana_max = hero_stats.mana_max
	mana_max = 0
	mana_regen = hero_stats.mana_regen
	energy_max = hero_stats.energy_max
	energy = energy_max
	energy_regen = hero_stats.energy_regen
	move_speed = hero_stats.move_speed
	attack_damage = hero_stats.attack_damage
	attack_speed = hero_stats.attack_speed
	attack_move_speed = hero_stats.attack_move_speed
	physical_critical_chance = hero_stats.physical_critical_chance
	physical_critical_multiplier = hero_stats.physical_critical_multiplier
