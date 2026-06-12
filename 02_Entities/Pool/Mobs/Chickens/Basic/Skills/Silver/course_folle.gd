class_name SE_CourseFolle
extends SkillEffect

# Talent "Course folle": à l'apparition, gagne +_ms_bonus_percent % de Movement Speed
# pendant _duration secondes.

@export var _ms_bonus_percent: float = 30.0
@export var _duration: float = 3.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity

	var modifier := StatModifier.new()
	modifier.id = &"CourseFolle"
	modifier.stat_type = EntityStats.StatType.MS
	modifier.calc_type = StatModifier.CalcType.MULT
	modifier.value = _ms_bonus_percent / 100.0
	chicken.stat_modifiers_registry.register_modifier(modifier)

	chicken.battle_callback_registry.register_oneshot(_duration, func() -> void:
		chicken.stat_modifiers_registry.remove_modifier(EntityStats.StatType.MS, "CourseFolle")
	)


func get_description() -> String:
	return "À son apparition, gagne +" + _value(_ms_bonus_percent) + "% de vitesse de " \
		+ "déplacement pendant " + _value(_duration) + " s."
