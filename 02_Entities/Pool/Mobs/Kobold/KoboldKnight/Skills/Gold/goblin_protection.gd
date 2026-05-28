class_name SE_GoblinProtection
extends SkillEffect

@export var _total_shield: float = 500.0

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	_owner.battle_callback_registry.register_battle_start(&"Goblin Protection", func() -> void:
		if _owner != null and is_instance_valid(_owner):
			var allies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
			var shield_gain: float = _total_shield/(allies.size())
			for entity in allies:
				_owner.alterations.inflict_condition_stacks(entity, shield_gain, Alteration.Type.SHIELD, &"Goblin Protection")
				ShieldVfxSpawner.spawn_on(entity)
	)
