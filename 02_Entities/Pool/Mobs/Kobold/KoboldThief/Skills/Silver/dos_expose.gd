class_name SE_DosExpose
extends SkillEffect

# Talent "Dos exposé": le Coup dans le dos inflige +_bonus dégâts physiques si la cible a
# moins de 50% PV. Écrit DOS_EXPOSE_META, lu par l'ultimate.

@export var _bonus: float = 0.25


func apply(ctx: SkillContext) -> void:
	ctx.entity.set_meta(KoboldThief.DOS_EXPOSE_META, _bonus)


func get_description() -> String:
	return "Renforce Coup dans le dos : +" + _value(_bonus * 100) + "% de " \
		+ "[[PHYSICAL_DAMAGE]] bonus si la cible est sous " + _value(50) + "% de ses PV."
