class_name CharacterPoisonStats
extends Resource

# Dictionary of all stacks on the entity sorted by entity source
var poison_stacks_ref: Dictionary[int, int] #Key=<entity_id, Value=stacks of poison>

signal poison_stacks_changed(new_poison_stacks: int)
var poison_stacks: int:
	get: return poison_stacks
	set(value):
		if value == poison_stacks: return
		poison_stacks = value
		poison_stacks_changed.emit(poison_stacks)

var poison_duration: int # Number of ticks the poison do before disapearing

var periodica_agaricus_activated: bool # True if the player has at least one of this card
var periodica_agaricus_stacks: int # Number of stack applied each tick
var periodica_agaricus_period: float # Time between applying 2 stacks (in s)

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
