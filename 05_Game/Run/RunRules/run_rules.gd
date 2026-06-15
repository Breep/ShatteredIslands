# Règles économiques d'un Run : gold de départ, revenu fixe par confrontation,
# intérêts gagnés par tranche de gold détenu (capés). Sérialisable en .tres.
class_name RunRules
extends Resource

@export var gold_starting_run: int = 300
@export var gold_per_confrontation: int = 50
@export var interest_gold_threshold: int = 10
@export var interest_max: int = 5
@export var tmp_hero_levels: Array[int] = [1, 3, 4, 5, 7]
