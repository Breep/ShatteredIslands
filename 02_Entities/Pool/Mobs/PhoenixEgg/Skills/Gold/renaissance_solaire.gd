class_name SE_RenaissanceSolaireOeuf
extends SkillEffect

# Talent "Renaissance solaire" (Œuf): si l'œuf réussit son Éclosion solaire, le Phoenix
# revient avec 100% PV au lieu de 50% (drapeau lu par l'ultimate).


func apply(ctx: SkillContext) -> void:
	ctx.entity.set_meta(SE_EclosionSolaire.FULL_HP_META, true)
