class_name CharacterStats
extends Resource

@export var health_max: int
var health: int = health_max

@export var auto_attack: CharacterAutoAttackStats
@export var defense: DefenseCharacterStats
@export var fire: FireCharacterStats
@export var storm: StormCharacterStats
@export var heal: HealCharacterStats
@export var hp: HpCharacterStats
@export var poison: PoisonCharacterStats
@export var shadow: ShadowCharacterStats

# Current armor on the character (like a shield, a second health bar)
# Decreases by taking damage: 1 damage = 1 armor stack consumed
var armor_stacks: int = 0 

# Current pacify stacks on the hero (reduce auto attack damage)
# Decreases by attacking: 1 auto attack = 1 pacify stack consumed
var pacify_stacks: int = 0

# Current vulnerability stacks on the hero (increase ALL attacker crit chance on character)
# Decreases by 10% each second with a minimum of 10 stacks
var vulnerability_stacks: int = 0
