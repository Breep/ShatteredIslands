class_name SE_HelpingHand
extends SkillEffect

@export var _period: float = 3.0
@export var _heal_ap_ratio: float = 300.0

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	
	var amount: float = _owner.stats.attack_power * _heal_ap_ratio/100
	
	_owner.battle_callback_registry.register_periodic(&"Helping Hand", _period, func() -> void:
		if _owner == null or not is_instance_valid(_owner): return
		var entity: Entity = _owner.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ALLY_INCLUDING_SELF)
		
		if entity == null or not is_instance_valid(entity): return
		_owner.heal.direct(entity, amount, &"Helping Hand")
	)


func get_description() -> String:
	return "Toutes les " + _value(_period) + " s, soigne l'allié le plus bas en PV " \
		+ "(lui compris) de " + _value(_heal_ap_ratio) + "% de sa puissance magique."
