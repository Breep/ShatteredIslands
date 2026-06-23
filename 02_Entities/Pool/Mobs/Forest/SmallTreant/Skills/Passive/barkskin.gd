class_name SE_Barkskin
extends SkillEffect

## Passive "Écorce épineuse": au début du combat, accumule des stacks de Thorn
## proportionnels au niveau (niveau × _stacks_per_level_percent %).

@export var _stacks_per_level_percent: float = 200.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity

	_owner.battle_callback_registry.register_battle_start(&"Barkskin", func() -> void:
		if not is_instance_valid(_owner): return
		var stacks: float = _owner.progression.level * _stacks_per_level_percent / 100.0
		if stacks > 0:
			_owner.alterations.direct_stack(_owner, stacks, Alteration.Type.THORN, &"Barkskin")
	)


func get_description() -> String:
	return "Au début du combat, gagne des stacks de Thorn égaux à " \
		+ _value(_stacks_per_level_percent) + "% de son niveau."
