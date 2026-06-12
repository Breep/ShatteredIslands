class_name SE_GoblinHorde
extends SkillEffect

@export var _amount_per_ally: float = 1.0
@export var _stat_type: EntityStats.StatType = EntityStats.StatType.CRIT_CHANCE

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	
	_owner.battle_callback_registry.register_battle_start(&"Goblin Horde", func() -> void:
		var allies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
		var allies_number: int = allies.size()
		var mod := StatModifier.new()
		mod.value = allies_number * _amount_per_ally
		mod.calc_type = StatModifier.CalcType.ADD
		mod.id = &"Goblin Horde"
		mod.stat_type = _stat_type
		_owner.stat_modifiers_registry.register_modifier(mod)
		)


func get_description() -> String:
	return "Au début du combat, gagne " + _value(_amount_per_ally) + " " \
		+ _stat_token() + " pour chaque allié vivant."


# Token de dictionnaire correspondant à la stat boostée (pour la coloration et le
# tooltip). Repli sur un libellé neutre si la stat n'a pas d'entrée dédiée.
func _stat_token() -> String:
	match _stat_type:
		EntityStats.StatType.ARMOR: return "[[ARMOR]]"
		EntityStats.StatType.MAGIC_RESIST: return "[[MR]]"
		EntityStats.StatType.POISON_RESIST: return "[[POISON_RESISTANCE]]"
		EntityStats.StatType.DODGE: return "[[DODGE]]"
		EntityStats.StatType.SCALE: return "[[SCALE]]"
		EntityStats.StatType.CRIT_CHANCE: return "[[CRIT_CHANCE]]"
		EntityStats.StatType.CRIT_MULT: return "[[CRIT_MULTIPLIER]]"
		EntityStats.StatType.AD: return "[[WARRIOR]]"
		_: return "de statistique"
