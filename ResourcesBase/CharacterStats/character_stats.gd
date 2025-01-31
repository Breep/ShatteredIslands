class_name CharacterStats
extends Resource

@export var health_max: int
var health: int

@export var auto_attack: CharacterAutoAttackStats
@export var defense: CharacterDefenseStats
@export var fire: CharacterFireStats
@export var storm: CharacterStormStats
@export var heal: CharacterHealStats
@export var hp: CharacterLifeStats
@export var poison: CharacterPoisonStats
@export var shadow: CharacterShadowStats

# Current pacify stacks on the hero (reduce auto attack damage)
# Decreases by attacking: 1 auto attack = 1 pacify stack consumed
var pacify_stacks: int = 0

# Current vulnerability stacks on the hero (increase ALL attacker crit chance on character)
# Decreases by 10% each second with a minimum of 10 stacks
var vulnerability_stacks: int = 0
