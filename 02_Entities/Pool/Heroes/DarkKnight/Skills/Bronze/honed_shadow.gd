class_name SE_HonedShadow
extends SkillEffect

# Bronze Honed Shadow: increases Shadow Blade's trigger chance. Only affects natural
# auto-attack triggers (the passive reads the meta in its chance roll; the ultimate's
# forced triggers don't roll).

@export var _chance_bonus: float = 5.0


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_ShadowBlade.META_CHANCE_BONUS, _chance_bonus)
