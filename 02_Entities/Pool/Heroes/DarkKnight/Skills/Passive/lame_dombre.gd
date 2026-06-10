class_name SE_LameDOmbre
extends SkillEffect

# Passif Lame d'Ombre: chaque auto-attaque a une chance de déclencher un projectile
# contrôlé par le deck (base = Nuit Noire) sur la cible courante. perform_trigger()
# centralise l'effet d'un déclenchement — naturel (jet de chance) ou forcé par
# l'ultimate — et les talents le modulent via des meta posées sur l'entité.

const META_CHANCE_BONUS := &"dk_chance_bonus"      # Bronze1 Ombre Affûtée
const META_SHIELD_RATIO := &"dk_shield_ratio"      # Bronze2 Garde d'Éclipse
const META_APPLY_WEAKNESS := &"dk_apply_weakness"  # Silver1 Soif Occulte
const META_APPLY_VULN := &"dk_apply_vuln"          # Silver2 Éclat Multiplié
const META_ULT_EXTRA := &"dk_ult_extra"            # Gold2 Tempête d'Éclipse
const META_PROJ_SIZE := &"dk_proj_size"            # Gold1 Éclipse Lourde

@export var _base_chance: float = 15.0


func apply(ctx: SkillContext) -> void:
	var dk: Entity = ctx.entity
	if dk == null:
		Verbose.error("SE_LameDOmbre: null owner", Verbose.Category.ENTITY_MODULE)
		return

	dk.projectile.register_projectile(Projectile.Type.NUIT_NOIRE)

	var modifier := AutoAttackModifier.new()
	modifier.id = &"LameDOmbre"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var source: Entity = data.get(AutoAttackModifier.VarType.SOURCE)
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(source) or not is_instance_valid(target):
			return
		var chance: float = _base_chance + source.get_meta(META_CHANCE_BONUS, 0.0)
		if not Utils.is_randomize_modifier_active(chance, source.battle_id, "LameDOmbre"):
			return
		perform_trigger(source, target)
	dk.auto_attack_modifier_registry.register_modifier(modifier)


# Effet d'un déclenchement de Lame d'Ombre. Static pour être réutilisé tel quel
# par l'ultimate (déclenchements forcés). Lit les meta posées par les talents.
static func perform_trigger(dk: Entity, target: Entity) -> void:
	if not is_instance_valid(dk) or not is_instance_valid(target):
		return

	var size: int = dk.get_meta(META_PROJ_SIZE, Projectile.Size.SMALL)
	dk.projectile.fire_random(target, dk, size)

	var shield_ratio: float = dk.get_meta(META_SHIELD_RATIO, 0.0)
	if shield_ratio > 0.0:
		dk.alterations.inflict_condition_stacks(
			dk, dk.stats.attack_damage * shield_ratio, Alteration.Type.SHIELD, &"Garde d'Éclipse")

	if dk.get_meta(META_APPLY_WEAKNESS, false):
		dk.alterations.inflict_condition_stacks(target, 1.0, Alteration.Type.WEAKNESS, &"Soif Occulte")

	if dk.get_meta(META_APPLY_VULN, false):
		dk.alterations.inflict_condition_stacks(target, 1.0, Alteration.Type.VULNERABILITY, &"Éclat Multiplié")
