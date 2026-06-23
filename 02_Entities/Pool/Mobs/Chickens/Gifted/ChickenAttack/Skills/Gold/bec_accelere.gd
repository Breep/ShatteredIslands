class_name SE_BecAccelere
extends SkillEffect

# Talent "Bec accéléré": le Bec martial passe en combo _combo_period (3 au lieu de 5).

@export var _combo_period: int = 3


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.set_meta(SE_BecMartial.COMBO_PERIOD_META, _combo_period)


func get_description() -> String:
	return "Son Bec martial se déclenche désormais toutes les " + _value(_combo_period) + " attaques."
