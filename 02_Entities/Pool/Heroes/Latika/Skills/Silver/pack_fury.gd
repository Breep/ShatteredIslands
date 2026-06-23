class_name SE_PackFury
extends SkillEffect

# Talent Silver "Furie de la Meute" : les auto-attaques des acolytes de Latika
# appliquent _vulnerability_stacks stack(s) de Vulnerability à leur cible. Posé sur
# le acolyte_modifiers_registry → cloné dans chaque acolyte à son spawn
# (cf. Pool/CLAUDE.md §8). Pression coordonnée / amplification de meute.

@export var _vulnerability_stacks: float = 1.0


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_PackFury: null owner", Verbose.Category.ENTITY_MODULE)
		return

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"PackFuryVulnerability"
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(data: Dictionary) -> void:
		var source: Entity = data.get(AutoAttackModifier.VarType.SOURCE)
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(source) or not is_instance_valid(target):
			return
		source.alterations.direct_stack(
			target, _vulnerability_stacks, Alteration.Type.VULNERABILITY, &"PackFuryVulnerability")
	latika.acolyte_modifiers_registry.auto_attack_modifier_registry.register_modifier(aa_mod)


func get_description() -> String:
	return "Les auto-attaques des loups de Latika appliquent " + _value(_vulnerability_stacks) \
		+ " [[VULNERABILITY]] à leur cible."
