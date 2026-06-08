class_name SE_DepartFulgurant
extends SkillEffect

# Talent "Départ fulgurant": commence le combat avec _mana Mana (l'ultimate part donc quasi
# immédiatement).

@export var _mana: float = 29.0


func apply(ctx: SkillContext) -> void:
	var thief: Entity = ctx.entity
	thief.battle_callback_registry.register_battle_start(&"DepartFulgurant", func() -> void:
		thief.stats.mana = _mana
	)
