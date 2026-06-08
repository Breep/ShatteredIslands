class_name SE_FocusGamma
extends SkillEffect

# Talent "Focus gamma": la tourelle gagne _as_per_second_percent % d'attack speed par
# seconde passée sur la même cible. Remis à zéro au changement de cible.

@export var _as_per_second_percent: float = 1.0


func apply(ctx: SkillContext) -> void:
	var turret: GammaTurret = ctx.entity as GammaTurret
	if turret == null:
		Verbose.error("SE_FocusGamma: owner is not a GammaTurret", Verbose.Category.ENTITY_MODULE)
		return

	# Boxed pour que le compteur vive par instance (resource SkillEffect partagée).
	var stacks: Array[int] = [0]

	turret.battle_callback_registry.register_periodic(&"FocusGammaTick", 1.0, func() -> void:
		if turret.auto_attack.get_current_target() == null:
			return
		stacks[0] += 1
		var modifier := StatModifier.new()
		modifier.id = &"FocusGamma"
		modifier.stat_type = EntityStats.StatType.AS
		modifier.value = stacks[0] * _as_per_second_percent / 100.0
		turret.stat_modifiers_registry.register_modifier(modifier)
	, true)

	turret.auto_attack.target_changed.connect(func(_new_target: Entity) -> void:
		if stacks[0] == 0:
			return
		stacks[0] = 0
		turret.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AS, "FocusGamma")
	)
