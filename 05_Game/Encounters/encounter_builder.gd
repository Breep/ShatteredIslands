class_name EncounterBuilder

# Convertit une EncounterDef + la liste des players en TavernEncounter prêt
# à être affiché par EncounterDisplay.
#
# - Instancie les scènes des masters/slaves
# - Reporte les fixed_slot_id dans encounter.fixed_placements
# - Les players sont ajoutés tels quels (déjà instanciés par PlayerManager)

static func build(def: EncounterDef, players: Array[Hero]) -> TavernEncounter:
	var encounter := TavernEncounter.new()
	encounter.players = players

	if def == null:
		push_warning("EncounterBuilder: EncounterDef null, encounter sera vide")
		return encounter

	for placement: EntityPlacement in def.masters:
		var entity: Entity = _instantiate_placement(placement, def, "master")
		if entity == null:
			continue
		encounter.masters.append(entity)
		if placement.fixed_slot_id != &"":
			encounter.fixed_placements[entity] = placement.fixed_slot_id

	for placement: EntityPlacement in def.slaves:
		var entity: Entity = _instantiate_placement(placement, def, "slave")
		if entity == null:
			continue
		encounter.slaves.append(entity)
		if placement.fixed_slot_id != &"":
			encounter.fixed_placements[entity] = placement.fixed_slot_id

	return encounter


static func _instantiate_placement(placement: EntityPlacement, def: EncounterDef, role: String) -> Entity:
	if placement == null:
		push_warning("EncounterBuilder: %s placement null dans '%s'" % [role, def.encounter_name])
		return null
	if placement.scene == null:
		push_warning("EncounterBuilder: %s placement sans scene dans '%s'" % [role, def.encounter_name])
		return null
	return placement.scene.instantiate()
