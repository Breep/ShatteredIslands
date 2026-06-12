class_name SE_RenaissanceSolaire
extends SkillEffect

# Talent "Renaissance solaire" (Phoenix): gagne +_ap_bonus AP jusqu'à la fin du combat,
# CUMULATIF à chaque renaissance. Le compteur de résurrections est transporté
# phoenix → œuf → phoenix via RESURRECTION_COUNT_META (incrémenté à chaque éclosion).
# Bonus appliqué = _ap_bonus × (compteur + 1) → +30 au 1er phoenix, +60 après 1 renaissance, etc.

const RESURRECTION_COUNT_META := &"phoenix_resurrection_count"

@export var _ap_bonus: float = 30.0


func apply(ctx: SkillContext) -> void:
	var phoenix: Entity = ctx.entity
	var resurrection_count: int = phoenix.get_meta(RESURRECTION_COUNT_META, 0)
	var modifier := StatModifier.new()
	modifier.id = &"RenaissanceSolaire"
	modifier.stat_type = EntityStats.StatType.AP
	modifier.value = _ap_bonus * float(resurrection_count + 1)
	phoenix.stat_modifiers_registry.register_modifier(modifier)


func get_description() -> String:
	return "Gagne +" + _value(_ap_bonus) + " de puissance magique jusqu'à la fin du combat, " \
		+ "et +" + _value(_ap_bonus) + " de plus à chaque renaissance (cumulatif)."
