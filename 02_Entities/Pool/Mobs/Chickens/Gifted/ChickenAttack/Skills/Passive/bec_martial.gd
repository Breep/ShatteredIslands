class_name SE_BecMartial
extends SkillEffect

# Passif "Bec martial": toutes les _combo_period attaques (combo), la suivante inflige
# AD x (100 + _damage_mult_bonus)% dégâts physiques. Le talent "Bec accéléré" abaisse la
# période via la meta COMBO_PERIOD_META.

const COMBO_PERIOD_META := &"chicken_attack_combo"

@export var _combo_period: int = 5
@export var _damage_mult_bonus: float = 25.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.set_meta(COMBO_PERIOD_META, _combo_period)

	var count: Array[int] = [0]
	chicken.auto_attack_completed.connect(func(_attacker: Entity) -> void:
		var period: int = chicken.get_meta(COMBO_PERIOD_META, _combo_period)
		count[0] += 1
		if count[0] == period - 1:
			_arm_combo(chicken)
		elif count[0] >= period:
			count[0] = 0
	)


func _arm_combo(chicken: Entity) -> void:
	var modifier := AutoAttackModifier.new()
	modifier.id = &"BecMartial"
	modifier.is_one_time_effect = true
	modifier.damage_modifier_callback = func(data: Dictionary) -> void:
		data[AutoAttackModifier.VarType.DAMAGE_MUL] += _damage_mult_bonus
	chicken.auto_attack_modifier_registry.register_modifier(modifier)
