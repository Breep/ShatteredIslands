class_name GlossaryEntry
extends Resource

# Une ligne de glossaire : un terme, sa catégorie et une description joueur.
# La description peut contenir les tokens BBCode du TooltipManager ([[CLE]],
# {{COLOR:X}}, [[ICON:X]]) afin d'être rendue avec les mêmes couleurs et icônes
# que les tooltips en jeu.

@export var term: String
@export var category: String
@export_multiline var description: String
@export var icon_key: String
