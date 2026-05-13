# Une étape de Run : une phase Taverne suivie d'une phase Combat.
# Les métadonnées macro (icône carte, logo du gang ennemi, nom du niveau)
# seront ajoutées dans une passe ultérieure.
class_name Confrontation
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export var tavern_encounter: TavernEncounter
@export var fighting_encounter: FightingEncounter
