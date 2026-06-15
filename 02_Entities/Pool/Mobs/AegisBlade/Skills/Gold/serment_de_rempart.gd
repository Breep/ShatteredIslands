class_name SE_SermentDeRempart
extends SkillEffect

# Talent "Serment de rempart": l'Aegis Blade gagne +_ad_bonus AD et +_as_bonus AS.

@export var _ad_bonus: float = 20.0
@export var _as_bonus: float = 0.25  # +25% AS


func apply(ctx: SkillContext) -> void:
	var blade: AegisBlade = ctx.entity as AegisBlade
	if blade == null:
		Verbose.error("SE_SermentDeRempart: owner is not an AegisBlade", Verbose.Category.ENTITY_MODULE)
		return

	var ad_mod := StatModifier.new()
	ad_mod.id = &"SermentAD"
	ad_mod.stat_type = EntityStats.StatType.AD
	ad_mod.value = _ad_bonus
	blade.stat_modifiers_registry.register_modifier(ad_mod)

	var as_mod := StatModifier.new()
	as_mod.id = &"SermentAS"
	as_mod.stat_type = EntityStats.StatType.AS
	as_mod.value = _as_bonus
	blade.stat_modifiers_registry.register_modifier(as_mod)
