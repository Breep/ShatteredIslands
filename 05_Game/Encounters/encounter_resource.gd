class_name EncounterResource
extends Resource

@export var encounter_id: StringName = &""
@export var display_name: String = ""
@export_multiline var design_notes: String = ""  # commentaires designer, pas affichés en jeu
@export var entity_specs: Array[EntitySpec] = []  # tous specs confondus, ordre = ordre d'instantiation
