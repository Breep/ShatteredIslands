class_name SE_CrushingEclipse
extends SkillEffect

# Gold Crushing Eclipse: Shadow Blade fires BIG_PROJECTILE instead of SMALL. Sets the
# size meta read by SE_ShadowBlade.perform_trigger. No BIG variant of Nightfall is
# provided: if the player's deck holds no BIG projectile, the pool filter is empty and
# the passive fires nothing — an assumed penalty. The talent only pays off for a player
# who built a BIG-projectile strategy.


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_ShadowBlade.META_PROJ_SIZE, Projectile.Size.BIG)
