class_name SE_RebondGamma
extends SkillEffect

# Ultimate "Rebond Gamma": pendant _duration secondes, chaque auto-attaque gagne
# +_bonus_bounces rebonds. Le bonus est ajouté une seule fois par projectile (au
# premier impact, avant le test de rebond dans Projectile._on_hit).

@export var _bonus_bounces: float = 2.0
@export var _duration: float = 4.0


func apply(ctx: SkillContext) -> void:
	var turret: GammaTurret = ctx.entity as GammaTurret
	if turret == null:
		Verbose.error("SE_RebondGamma: owner is not a GammaTurret", Verbose.Category.ENTITY_MODULE)
		return

	var modifier := AutoAttackModifier.new()
	modifier.id = &"RebondGamma"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var projectile: Projectile = data.get(AutoAttackModifier.VarType.PROJECTILE)
		if projectile == null:
			return
		if projectile.has_meta(&"rebond_gamma"):
			return
		projectile.set_meta(&"rebond_gamma", true)
		projectile.add_bounce(_bonus_bounces)
	turret.auto_attack_modifier_registry.register_modifier(modifier)

	turret.battle_callback_registry.register_oneshot(_duration, func() -> void:
		turret.auto_attack_modifier_registry.unregister_modifier(&"RebondGamma")
	)
