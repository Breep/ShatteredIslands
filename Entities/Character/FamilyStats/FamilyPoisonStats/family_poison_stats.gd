class_name FamilyPoisonStats
extends FamilyStats

@export_group("Periodica Agaricus")
@export var periodica_agaricus_activated: bool # True if the player has at least one of this card
@export var periodica_agaricus_stacks: int # Number of stack applied each tick
@export var periodica_agaricus_period: float # Time between applying 2 stacks (in s)
