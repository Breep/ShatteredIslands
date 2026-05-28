class_name SE_RageCry
extends SkillEffect

@export var _as_bonus: float = 60.0
@export var _as_length: float = 5.0
@export var _radius: float = 5.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	var allies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES, _radius)
	
	var mod := StatModifier.new()
	mod.id = &"BloodLust"
	mod.stat_type = EntityStats.StatType.AS
	mod.value = _as_bonus/100
	
	for entity in allies:
		if is_instance_valid(entity) && entity != null:
			entity.stat_modifiers_registry.register_modifier(mod)
			entity.battle_callback_registry.register_oneshot(_as_length, func() -> void:
				entity.stat_modifiers_registry.unregister_modifier(mod)
			)
	
	
	
