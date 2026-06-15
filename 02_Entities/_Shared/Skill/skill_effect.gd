class_name SkillEffect
extends Resource

func apply(_ctx: SkillContext) -> void:
	pass


func get_description() -> String:
	return ""


# Formate une valeur numérique pour les descriptions de skill : nombre propre
# (sans .0 superflu), en bleu clair via le token couleur du dictionnaire de
# tooltips (résolu par TooltipManager.render_bbcode au moment de l'affichage).
func _value(v: float) -> String:
	var num: String = str(int(v)) if is_equal_approx(v, roundf(v)) else str(snappedf(v, 0.1))
	return "{{COLOR:VALUE_COLOR}}%s{{/COLOR}}" % num
