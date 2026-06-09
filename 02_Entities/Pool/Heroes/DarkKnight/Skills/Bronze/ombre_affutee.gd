class_name SE_OmbreAffutee
extends SkillEffect

# Bronze Ombre Affûtée: augmente la chance de déclenchement de Lame d'Ombre.
# Ne touche que les déclenchements naturels par auto-attaque (le passif lit la
# meta dans son jet de chance ; les déclenchements forcés de l'ult ne jettent pas).

@export var _chance_bonus: float = 5.0


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_LameDOmbre.META_CHANCE_BONUS, _chance_bonus)
