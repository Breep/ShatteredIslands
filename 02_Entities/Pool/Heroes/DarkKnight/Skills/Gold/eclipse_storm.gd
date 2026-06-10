class_name SE_EclipseStorm
extends SkillEffect

# Gold Eclipse Storm: the Eclipse ultimate triggers Shadow Blade _extra_triggers more
# times (5 → 7 by default). Read by SE_Eclipse via META_ULT_EXTRA.

@export var _extra_triggers: int = 2


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_ShadowBlade.META_ULT_EXTRA, _extra_triggers)
