# Résultat d'une Confrontation : consommé par le GameRunner pour appliquer
# les conséquences (gold, etc.) une fois la confrontation terminée.
class_name ConfrontationResult
extends Resource

enum Outcome { WIN, LOSS }

@export var outcome: Outcome
