class_name CharacterPoisonStats
extends Resource

@export var periodic_stacks_number: int # Number of stack applied each tick
@export var periodic_stacks_period: float # Time between applying 2 stacks (in s)
@export var poison_resist: int # % of poison damage less taken
@export var poison_cloud_stacks_number: int # Number of stack applied each tick
@export var poison_cloud_stacks_period: float # Time between applying 2 stacks (in s)
@export var poison_cloud_range: int # Range of the poison cloud (in m)
@export var movement_stacks_number: int # Number of stack applied each amount of distance moved
@export var movement_stacks_distance: int # Distance needed for applying movement_stacks
@export var multiply_damage: float # Poison damage is multiplied by this (modified with epic card)
