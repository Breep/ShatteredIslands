class_name FightingEntitySpec
extends EntitySpec

# Puisqu'on a enlevé le CombatRole, on a juste besoin de savoir dans 
# quel camp cette entité se bat (1 = Joueur, 2 = Ennemi, 3 = Neutre ?)
@export var team: int = 2
