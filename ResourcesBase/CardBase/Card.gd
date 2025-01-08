extends Resource
class_name Card

enum Rarity {COMMON, RARE, EPIC}

#Description carte
@export var name : String
@export var image : Texture2D
@export var famille : Texture2D
@export var cost : int
@export var description : String
@export var lvl : int
@export var rarity : Rarity

#attack stats
@export var attack_speed_increase : float
@export var attack_damage : float
@export var double_attack_chance : float
@export var lifesteal : float
@export var crit_chance : float
@export var crit__damage_multiplier : float

#defense stats
@export var health : float
@export var armor : float
@export var regen_health : float

#fire
#@export var ignite : int
