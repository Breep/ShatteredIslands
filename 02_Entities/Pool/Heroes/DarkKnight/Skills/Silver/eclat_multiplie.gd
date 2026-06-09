class_name SE_EclatMultiplie
extends SkillEffect

# Silver Éclat Multiplié: chaque déclenchement de Lame d'Ombre applique Vulnerability
# à la cible. L'application vit dans SE_LameDOmbre.perform_trigger, activée par cette meta.

func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_LameDOmbre.META_APPLY_VULN, true)
