class_name SE_GoblinHorde
extends SkillEffect

@export var _amount_per_ally: float = 1.0
@export var _stat_type: EntityStats.StatType = EntityStats.StatType.CRIT_CHANCE

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	
	_owner.battle_callback_registry.register_battle_start(&"Goblin Horde", func() -> void:
		var allies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
		var allies_number: int = allies.size()
		var mod := StatModifier.new()
		mod.value = allies_number * _amount_per_ally
		mod.calc_type = StatModifier.CalcType.ADD
		mod.id = &"Goblin Horde"
		mod.stat_type = _stat_type
		_owner.stat_modifiers_registry.register_modifier(mod)
		)
