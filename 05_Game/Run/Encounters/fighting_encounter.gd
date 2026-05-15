# Encounter de combat : décrit l'île + les deux formations qui s'affrontent.
# Side A vs Side B (convention abstraite : pas de notion de "joueur" ici).
# Un Runner externe sait remplacer une des formations par celle d'une Party
# au moment de l'exécution.
class_name FightingEncounter
extends Encounter

@export var island_scene: PackedScene
@export var formation_a: FightingFormation
@export var formation_b: FightingFormation
