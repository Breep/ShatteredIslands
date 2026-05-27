# Ajoute un bonus de niveau à toutes les entités ennemies d'une FightingEncounter.
# Les specs joueur (entry != null) sont ignorées pour ne pas toucher au roaster.
class_name LevelBonusModifier
extends EncounterModifier

@export var bonus: int = 0


func apply(encounter: Encounter, _ctx: RunContext) -> Encounter:
	if bonus == 0 or encounter == null:
		return encounter
	if not (encounter is FightingEncounter):
		return encounter
	var fe: FightingEncounter = encounter as FightingEncounter
	var clone: FightingEncounter = fe.duplicate(true) as FightingEncounter
	_bump_formation_levels(clone.formation_a, bonus)
	_bump_formation_levels(clone.formation_b, bonus)
	return clone


static func _bump_formation_levels(formation: FightingFormation, lvl_bonus: int) -> void:
	if formation == null: return
	for spec: EntitySpec in formation.entity_specs:
		if spec.entry != null: continue  # skip player specs
		spec.level = clampi(spec.level + lvl_bonus, 1, 20)
