class_name GolemDeathUtils
extends RefCounted

# Utilitaire pour les passifs d'explosion des golems. À la mort, _on_died() appelle
# stop_combat_modules() AVANT d'exécuter les death modifiers → le TargetComponent est
# déjà stoppé (liste d'ennemis vidée). On récupère donc les ennemis directement via le
# SpawnManager, filtrés par équipe et par rayon.


static func enemies_in_radius(golem: Entity, radius: float) -> Array[Entity]:
	var result: Array[Entity] = []
	if golem == null:
		return result
	var spawn_manager: SpawnManager = golem.get_context().spawn_manager
	if spawn_manager == null:
		return result
	for entity: Entity in spawn_manager.get_entities():
		if not is_instance_valid(entity) or entity == golem:
			continue
		if entity.is_dead():
			continue
		if entity.team == golem.team:
			continue
		if entity.global_position.distance_to(golem.global_position) <= radius:
			result.append(entity)
	return result
