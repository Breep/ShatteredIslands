class_name SE_EclipseGuard
extends SkillEffect

# Bronze Eclipse Guard: each Shadow Blade trigger (natural or forced by the ult) grants
# the Dark Knight a Shield equal to _ad_ratio × AD + _ap_ratio × AP. The Shield
# application lives in SE_ShadowBlade.perform_trigger, read through these metas.

@export var _ad_ratio: float = 0.5
@export var _ap_ratio: float = 0.5


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_ShadowBlade.META_SHIELD_RATIO, _ad_ratio)
	ctx.entity.set_meta(SE_ShadowBlade.META_SHIELD_AP_RATIO, _ap_ratio)


func get_description() -> String:
	return "Chaque déclenchement de sa Lame d'Ombre lui octroie un [[SHIELD]] égal à " \
		+ _value(_ad_ratio * 100) + "% de ses dégâts d'attaque + " \
		+ _value(_ap_ratio * 100) + "% de sa puissance."
