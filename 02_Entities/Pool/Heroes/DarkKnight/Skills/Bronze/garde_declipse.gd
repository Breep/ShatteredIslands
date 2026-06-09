class_name SE_GardeDEclipse
extends SkillEffect

# Bronze Garde d'Éclipse: chaque déclenchement de Lame d'Ombre (naturel ou forcé
# par l'ult) octroie au Dark Knight un Shield égal à _shield_ratio × AD. La pose
# du Shield vit dans SE_LameDOmbre.perform_trigger, lue via cette meta.

@export var _shield_ratio: float = 3.0


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_LameDOmbre.META_SHIELD_RATIO, _shield_ratio)
