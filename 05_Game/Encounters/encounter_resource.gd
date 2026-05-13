# Base partagée par TavernEncounter et FightingEncounter.
# Porte uniquement l'identité et les notes designer ; les specs d'entités
# vivent dans les Formations rattachées aux encounters concrets.
class_name EncounterResource
extends Resource

@export var encounter_id: StringName = &""
@export var display_name: String = ""
@export_multiline var design_notes: String = ""
