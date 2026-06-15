class_name SE_EclipseGuard
extends SkillEffect

# Bronze Eclipse Guard: each Shadow Blade trigger (natural or forced by the ult) grants
# the Dark Knight a Shield equal to _shield_ratio × AD. The Shield application lives in
# SE_ShadowBlade.perform_trigger, read through this meta.

@export var _shield_ratio: float = 3.0


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_ShadowBlade.META_SHIELD_RATIO, _shield_ratio)


func get_description() -> String:
	return "Chaque déclenchement de sa Lame d'Ombre lui octroie un [[SHIELD]] égal à " \
		+ _value(_shield_ratio) + "× ses dégâts d'attaque."
