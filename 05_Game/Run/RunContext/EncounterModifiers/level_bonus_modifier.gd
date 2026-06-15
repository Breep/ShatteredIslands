# Ajoute un bonus de niveau à toutes les entités ennemies d'une FightingEncounter.
# Toute spec porte une entry ; on bump entry.level. Les specs joueur (entry
# rattachée à un roaster de la Party) sont ignorées pour ne pas toucher au roaster.
class_name LevelBonusModifier
extends EncounterModifier

@export var bonus: int = 0


func apply(encounter: Encounter, ctx: RunContext) -> Encounter:
	if bonus == 0 or encounter == null:
		return encounter
	if not (encounter is FightingEncounter):
		return encounter
	var fe: FightingEncounter = encounter as FightingEncounter
	var clone: FightingEncounter = fe.duplicate(true) as FightingEncounter
	var party: Party = ctx.party if ctx != null else null
	_bump_formation_levels(clone.formation_a, bonus, party)
	_bump_formation_levels(clone.formation_b, bonus, party)
	return clone


static func _bump_formation_levels(formation: FightingFormation, lvl_bonus: int, party: Party) -> void:
	if formation == null: return
	for spec: EntitySpec in formation.entity_specs:
		if spec.entry == null: continue
		if party != null and party.find_slot_of(spec.entry) != PlayerState.Slot.NONE:
			continue  # skip player specs
		spec.entry.level = clampi(spec.entry.level + lvl_bonus, 1, 20)
