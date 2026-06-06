class_name SE_ThornyLegacy
extends SkillEffect

## Talent 3 "Héritage épineux": à sa mort, transfère _transfer_percent % de ses stacks
## de Thorn à l'allié le plus proche.

@export var _transfer_percent: float = 25.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity

	var mod := DeathModifier.new()
	mod.id = &"Thorny Legacy"
	mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		var thorn: float = _owner.alterations.get_stacks(Alteration.Type.THORN)
		var transferred: float = thorn * _transfer_percent / 100.0
		if transferred <= 0: return
		# À la mort, le TargetComponent est déjà stoppé (listes vidées) → on cherche
		# l'allié le plus proche via le SpawnManager.
		var ally: Entity = _closest_ally(_owner)
		if is_instance_valid(ally):
			ally.alterations.add_stack(Alteration.Type.THORN, transferred)

	_owner.death_modifiers_registry.register_modifier(mod)


func _closest_ally(owner: Entity) -> Entity:
	var spawn_manager: SpawnManager = owner.get_context().spawn_manager
	if spawn_manager == null:
		return null
	var best: Entity = null
	var best_dist: float = INF
	for entity: Entity in spawn_manager.get_entities():
		if not is_instance_valid(entity) or entity == owner or entity.is_dead():
			continue
		if entity.team != owner.team:
			continue
		var dist: float = entity.global_position.distance_to(owner.global_position)
		if dist < best_dist:
			best_dist = dist
			best = entity
	return best
