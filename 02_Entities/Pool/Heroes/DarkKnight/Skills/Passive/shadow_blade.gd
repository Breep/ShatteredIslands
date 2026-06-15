class_name SE_ShadowBlade
extends SkillEffect

# Passive Shadow Blade: each auto-attack has a chance to trigger a controlled
# projectile (base: Nightfall) at the current target. perform_trigger() centralises
# a trigger's effect — natural (chance roll) or forced by the ultimate — and talents
# modulate it through meta set on the entity.

const META_CHANCE_BONUS := &"dk_chance_bonus"      # Bronze1 Honed Shadow
const META_SHIELD_RATIO := &"dk_shield_ratio"      # Bronze2 Eclipse Guard
const META_APPLY_WEAKNESS := &"dk_apply_weakness"  # Silver1 Occult Thirst
const META_APPLY_VULN := &"dk_apply_vuln"          # Silver2 Amplified Shard
const META_ULT_EXTRA := &"dk_ult_extra"            # Gold2 Eclipse Storm
const META_PROJ_SIZE := &"dk_proj_size"            # Gold1 Crushing Eclipse

@export var _base_chance: float = 15.0

func apply(ctx: SkillContext) -> void:
	var dk: Entity = ctx.entity
	if dk == null:
		Verbose.error("SE_ShadowBlade: null owner", Verbose.Category.ENTITY_MODULE)
		return

	dk.projectile.register_projectile(Projectile.Type.NIGHTFALL)

	var modifier := AutoAttackModifier.new()
	modifier.id = &"ShadowBlade"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var source: Entity = data.get(AutoAttackModifier.VarType.SOURCE)
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(source) or not is_instance_valid(target):
			return
		var chance: float = _base_chance + source.get_meta(META_CHANCE_BONUS, 0.0)
		if not Utils.is_randomize_modifier_active(chance, source.battle_id, "ShadowBlade"):
			return
		perform_trigger(source, target)
	dk.auto_attack_modifier_registry.register_modifier(modifier)


func get_description() -> String:
	return "Chaque auto-attaque a " + _value(_base_chance) + "% de chances de déclencher " \
		+ "un tir de projectile (Nightfall) sur sa cible courante."


# A Shadow Blade trigger's effect. Static so the ultimate reuses it verbatim (forced
# triggers). Reads the meta set by talents.
static func perform_trigger(dk: Entity, target: Entity) -> void:
	if not is_instance_valid(dk) or not is_instance_valid(target):
		return

	var size: int = dk.get_meta(META_PROJ_SIZE, Projectile.Size.SMALL)
	dk.projectile.fire_random(target, dk, size)

	var shield_ratio: float = dk.get_meta(META_SHIELD_RATIO, 0.0)
	if shield_ratio > 0.0:
		dk.alterations.inflict_condition_stacks(
			dk, dk.stats.attack_damage * shield_ratio, Alteration.Type.SHIELD, &"Eclipse Guard")

	if dk.get_meta(META_APPLY_WEAKNESS, false):
		dk.alterations.inflict_condition_stacks(target, 1.0, Alteration.Type.WEAKNESS, &"Occult Thirst")

	if dk.get_meta(META_APPLY_VULN, false):
		dk.alterations.inflict_condition_stacks(target, 1.0, Alteration.Type.VULNERABILITY, &"Amplified Shard")
