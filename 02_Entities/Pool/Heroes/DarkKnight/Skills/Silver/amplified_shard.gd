class_name SE_AmplifiedShard
extends SkillEffect

# Silver Amplified Shard: each Shadow Blade trigger applies Vulnerability to the target.
# The application lives in SE_ShadowBlade.perform_trigger, enabled by this meta.

func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_ShadowBlade.META_APPLY_VULN, true)


func get_description() -> String:
	return "Chaque déclenchement de sa Lame d'Ombre applique " + _value(1) + " [[VULNERABILITY]] à la cible."
