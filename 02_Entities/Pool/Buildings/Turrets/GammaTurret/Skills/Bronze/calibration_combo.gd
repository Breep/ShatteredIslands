class_name SE_CalibrationCombo
extends SkillEffect

# Talent "Calibration": le Tir Gamma passe en combo 3 (bonus toutes les 3 attaques
# au lieu de 4). Écrase la période effective posée par le passif (cf. SE_TirGamma).

@export var _combo_period: int = 3


func apply(ctx: SkillContext) -> void:
	var turret: GammaTurret = ctx.entity as GammaTurret
	if turret == null:
		Verbose.error("SE_CalibrationCombo: owner is not a GammaTurret", Verbose.Category.ENTITY_MODULE)
		return
	turret.set_meta(SE_TirGamma.COMBO_PERIOD_META, _combo_period)
