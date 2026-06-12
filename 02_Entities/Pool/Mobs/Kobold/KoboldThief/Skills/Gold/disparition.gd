class_name SE_Disparition
extends SkillEffect

# Talent "Disparition": active le mode "kill → furtivité". À chaque kill (cible morte après
# une auto-attaque), le KoboldThief redevient invisible et regagne son mana max (logique dans
# KoboldThief.notify_kill, aussi appelée par l'ultimate).


func apply(ctx: SkillContext) -> void:
	var thief: Entity = ctx.entity
	thief.set_meta(KoboldThief.DISPARITION_META, true)

	var modifier := AutoAttackModifier.new()
	modifier.id = &"Disparition"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(_data: Dictionary) -> void:
		var target: Entity = thief.auto_attack.get_current_target() if thief.auto_attack != null else null
		if is_instance_valid(target) and target.is_dead() and thief.has_method("notify_kill"):
			thief.notify_kill()
	thief.auto_attack_modifier_registry.register_modifier(modifier)


func get_description() -> String:
	return "À chaque élimination (cible tuée juste après une auto-attaque), " \
		+ "redevient invisible et regagne tout son [[MANA]]."
