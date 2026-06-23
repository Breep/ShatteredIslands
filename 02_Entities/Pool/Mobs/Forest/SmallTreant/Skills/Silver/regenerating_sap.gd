class_name SE_RegeneratingSap
extends SkillEffect

## Talent 2 "Sève régénérante": toutes les _period s, gagne un Shield égal à
## _shield_per_thorn_percent % des stacks de Thorn courants.

@export var _period: float = 12.0
@export var _shield_per_thorn_percent: float = 25.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity

	_owner.battle_callback_registry.register_periodic(&"Regenerating Sap", _period, func() -> void:
		if not is_instance_valid(_owner): return
		var thorn: float = _owner.alterations.get_stacks(Alteration.Type.THORN)
		var shield: float = thorn * _shield_per_thorn_percent / 100.0
		if shield > 0:
			_owner.alterations.direct_stack(_owner, shield, Alteration.Type.SHIELD, &"Regenerating Sap")
	, true)


func get_description() -> String:
	return "Toutes les " + _value(_period) + " s, gagne un [[SHIELD]] égal à " \
		+ _value(_shield_per_thorn_percent) + "% de ses stacks de Thorn."
