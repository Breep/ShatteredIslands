class_name SE_TirGamma
extends SkillEffect

# Passif "Tir Gamma": toutes les `_combo_period` auto-attaques, la prochaine attaque
# projectile inflige un bonus de dégâts physiques égal à _bonus_ad_percent % de l'AD.
# La période effective est posée en meta sur la tourelle pour que le talent
# "Calibration" (Bronze) puisse l'abaisser.

const COMBO_PERIOD_META := &"gamma_combo_period"

@export var _combo_period: int = 4
@export var _bonus_ad_percent: float = 100.0


func apply(ctx: SkillContext) -> void:
	var turret: GammaTurret = ctx.entity as GammaTurret
	if turret == null:
		Verbose.error("SE_TirGamma: owner is not a GammaTurret", Verbose.Category.ENTITY_MODULE)
		return

	turret.set_meta(COMBO_PERIOD_META, _combo_period)

	# Boxed pour que le compteur vive par instance (la resource SkillEffect peut être
	# partagée entre plusieurs tourelles via entity_desc).
	# On arme le bonus à l'avant-dernière attaque du combo (period - 1) pour qu'il soit
	# consommé pile par la period-ème, puis on remet le compteur à zéro à la fin du combo.
	var count: Array[int] = [0]
	turret.auto_attack_completed.connect(func(_attacker: Entity) -> void:
		var period: int = turret.get_meta(COMBO_PERIOD_META, _combo_period)
		count[0] += 1
		if count[0] == period - 1:
			_arm_bonus_shot(turret)
		elif count[0] >= period:
			count[0] = 0
	)


func _arm_bonus_shot(turret: GammaTurret) -> void:
	var modifier := AutoAttackModifier.new()
	modifier.id = &"TirGamma"
	modifier.is_one_time_effect = true
	modifier.damage_modifier_callback = func(data: Dictionary) -> void:
		data[AutoAttackModifier.VarType.DAMAGE_MUL] += _bonus_ad_percent
	turret.auto_attack_modifier_registry.register_modifier(modifier)
