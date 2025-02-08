class_name CharacterPoisonStats
extends Resource

var poison_effects: Array[PoisonEffect]

var poison_duration: int # Number of ticks the poison do before disapearing

var periodic_stacks_activated: bool # True if the player has at least one of this card
var periodic_stacks_number: int # Number of stack applied each tick
var periodic_stacks_period: float # Time between applying 2 stacks (in s)

var poison_resist: float # % of poison damage less taken

var poison_cloud_stacks_number: int # Number of stack applied each tick
var poison_cloud_stacks_period: float # Time between applying 2 stacks (in s)
var poison_cloud_range: int # Range of the poison cloud (in m)

var multiply_damage_activated: bool # If the skill is activated
var multiply_damage: float # Poison damage is multiplied by this (modified with epic card)
