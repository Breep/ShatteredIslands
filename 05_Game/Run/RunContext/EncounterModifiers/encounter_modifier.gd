# Base abstraite : transforme un Encounter avant son exécution.
# Stockés dans RunContext.encounter_modifiers, déroulés par le
# ConfrontationRunner à la matérialisation d'une Confrontation.
# Convention : ne pas muter l'encounter d'entrée — retourner un clone modifié.
class_name EncounterModifier
extends Resource


func apply(encounter: Encounter, _ctx: RunContext) -> Encounter:
	# Default no-op. Surcharger dans les classes filles.
	return encounter
