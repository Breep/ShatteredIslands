class_name FamilyPoisonStats
extends FamilyStats

@export_group("Periodica Agaricus")
@export var poison_flask_activated: bool # True if the player has at least one of this card
@export var poison_flask_stacks: int # Number of stack applied each tick
@export var poison_flask_period: float # Time between applying 2 stacks (in s)
