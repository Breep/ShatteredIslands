class_name CharacterPoisonStats
extends Resource

var poison_effects: Array[PoisonEffect]

var poison_duration: int # Number of ticks the poison do before disapearing

var periodic_stacks_activated: bool # True if the player has at least one of this card
var periodic_stacks_number: int # Number of stack applied each tick
var periodic_stacks_period: float # Time between applying 2 stacks (in s)

var poison_resist: float # % of poison damage less taken

var poison_cloud_activated # If this skill is activated
var poison_cloud_stacks_number: int # Number of stack applied each tick
var poison_cloud_stacks_period: float # Time between applying 2 stacks (in s)
var poison_cloud_range: int # Range of the poison cloud (in m)

var multiply_damage_activated: bool # If the skill is activated
var multiply_damage: float # Poison damage is multiplied by this (modified with epic card)

var fire_poison_activated: bool # If the skill is activated
var fire_poison_stacks_lost: int # Number of stack to be lost by the enemy to proc poison_fire
var fire_poison_damage: int # Damage of the poison fire (in % of enemy max hp)
