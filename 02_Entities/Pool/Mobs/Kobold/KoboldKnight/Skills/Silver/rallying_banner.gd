class_name SE_RallyingBanner
extends SkillEffect

@export var _defense_bonus: float = 30.0
var _owner: Entity

func apply(ctx: SkillContext) -> void:
	_owner = ctx.entity
	_owner.spawn_manager.entity_spawned.connect(_on_entity_spawned)
	
	var allies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
	
	for entity in allies:
		if not is_instance_valid(entity): continue
		entity.alterations.add_stack(Alteration.Type.DEFENSE, _defense_bonus, _owner, &"RallyingBanner")
		
	var mod := ActionModifier.new()
	mod.id = &"Rallying Banner"
	mod.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		var remaining_allies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
		for entity in remaining_allies: #TODO remaining entities empty
			if not is_instance_valid(entity): continue
			entity.alterations.add_stack(Alteration.Type.DEFENSE, _defense_bonus, null, &"RallyingBanner")
	_owner.death_modifiers_registry.register_modifier(mod)
	
	

func _on_entity_spawned(entity: Entity) -> void:
	if not is_instance_valid(entity): return
	if entity.team != _owner.team: return
	entity.alterations.add_stack(Alteration.Type.DEFENSE, _defense_bonus, _owner, &"RallyingBanner")
