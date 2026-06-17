class_name SE_CoquilleSolaire
extends SkillEffect

# Talent "Coquille solaire": la Comète de basse-cour se déclenche à _hp_threshold de PV
# (50%) au lieu de 35%.

@export var _hp_threshold: float = 0.5


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.set_meta(SE_CometeBasseCour.THRESHOLD_META, _hp_threshold)


func get_description() -> String:
	return "Sa Comète de basse-cour se déclenche désormais dès " + _value(_hp_threshold * 100.0) \
		+ "% de ses PV."
