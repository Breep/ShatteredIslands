class_name SE_AegisActive
extends SkillEffect

# Passif "Aegis active": à chaque attaque, convertit _convert_ratio des dégâts infligés en
# Shield donné à l'allié le plus blessé. Le talent "Fil protecteur" relève le ratio (meta).

const META_CONVERT_RATIO := &"aegis_convert_ratio"

@export var _convert_ratio: float = 0.25


func apply(ctx: SkillContext) -> void:
	var blade: AegisBlade = ctx.entity as AegisBlade
	if blade == null:
		Verbose.error("SE_AegisActive: owner is not an AegisBlade", Verbose.Category.ENTITY_MODULE)
		return

	var modifier := AutoAttackModifier.new()
	modifier.id = &"AegisActive"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var damage: float = data.get(AutoAttackModifier.VarType.DAMAGE, 0.0)
		if damage <= 0.0:
			return
		var ratio: float = blade.get_meta(META_CONVERT_RATIO, _convert_ratio)
		var ally: Entity = blade.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ALLY_INCLUDING_SELF)
		if is_instance_valid(ally):
			blade.alterations.inflict_condition_stacks(ally, damage * ratio, Alteration.Type.SHIELD, &"Aegis active")
	blade.auto_attack_modifier_registry.register_modifier(modifier)
