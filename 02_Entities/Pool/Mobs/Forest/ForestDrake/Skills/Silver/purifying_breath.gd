class_name SE_PurifyingBreath
extends SkillEffect

@export var _period: float = 6.0
@export var _cleanse_ap_ratio: float = 100.0

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	
	var amount: float = _owner.stats.attack_power * _cleanse_ap_ratio/100
	
	_owner.battle_callback_registry.register_periodic(&"Purifying Breath", _period, func() -> void:
		if _owner == null or not is_instance_valid(_owner): return
		var entity: Entity = _owner.target.get_target(TargetComponent.TargettingStrategy.HIGHEST_ALLY_DEBUFF_STACK)
		
		if entity == null or not is_instance_valid(entity): return
		_owner.alterations.direct_cleanse(entity, amount, &"Purifying Breath")
	)


func get_description() -> String:
	return "Toutes les " + _value(_period) + " s, applique un [[CLEANSE]] de " \
		+ _value(_cleanse_ap_ratio) + "% de sa puissance magique sur l'allié le plus affligé."
