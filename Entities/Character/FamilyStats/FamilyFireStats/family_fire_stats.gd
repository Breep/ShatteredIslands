class_name FamilyFireStats
extends FamilyStats

@export_group("Firebolt")
@export var firebolt_activated: bool # True if the player has at least one of this card
@export var firebolt_damage: float # Damage of the firebolt (in % of enemy current hp)
@export var firebolt_period: float # Period of time between 2 firebolts (in s)

@export_group("Meteor")
@export var meteor_activated: bool # True if the player has at least one of this card
@export var meteor_ignite_stacks: int # Ignite stacks applied to targets
@export var meteor_damage_per_stack: float # Magical damage done per stacks on the target
@export var meteor_period: float # Period of meteor spell cast

@export_group("Periodic Ignite")
@export var periodic_ignite_activated: bool # True if the player has at least one of this card
@export var periodic_ignite_stacks: int # Ignite stacks number applied each period
@export var periodic_ignite_period: float # Period of the periodic ignite (in s)
