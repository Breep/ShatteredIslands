class_name SE_FrappeDeRempart
extends SkillEffect

# Ultimate "Frappe de rempart": la prochaine attaque inflige AD x (100 + _damage_mult_bonus)%
# dégâts physiques et convertit _convert_ratio des dégâts en Shield donné à l'allié le plus
# blessé.

@export var _damage_mult_bonus: float = 150.0  # +150 → AD x 250%
@export var _convert_ratio: float = 1.5


func apply(ctx: SkillContext) -> void:
	var blade: AegisBlade = ctx.entity as AegisBlade
	if blade == null:
		Verbose.error("SE_FrappeDeRempart: owner is not an AegisBlade", Verbose.Category.ENTITY_MODULE)
		return

	var modifier := AutoAttackModifier.new()
	modifier.id = &"FrappeDeRempart"
	modifier.is_one_time_effect = true
	modifier.damage_modifier_callback = func(data: Dictionary) -> void:
		data[AutoAttackModifier.VarType.DAMAGE_MUL] += _damage_mult_bonus
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var damage: float = data.get(AutoAttackModifier.VarType.DAMAGE, 0.0)
		if damage <= 0.0:
			return
		var ally: Entity = blade.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ALLY_INCLUDING_SELF)
		if is_instance_valid(ally):
			blade.alterations.direct_stack(ally, damage * _convert_ratio, Alteration.Type.SHIELD, &"Frappe de rempart")
	blade.auto_attack_modifier_registry.register_modifier(modifier)
