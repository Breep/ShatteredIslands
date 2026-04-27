class_name ChickenShield
extends ChickenGifted

var _shield_strength_inherited: float
var _bonus_spawn: int
var _shield_per_attack: int

func init(bonus_spawn: int, shield_per_attack: int, shield_strength_inherited: float) -> Summon:
	_bonus_spawn = bonus_spawn
	_shield_per_attack = shield_per_attack
	_shield_strength_inherited = shield_strength_inherited
	return self

func _ready() -> void:
	
	if alterations != null:
		alterations.add_typed_stack(Alteration.Type.STRENGTH, Utils.ActionType.STACK_SHIELD, _shield_strength_inherited)
		alterations.add_stack(Alteration.Type.DEFENSE, _bonus_spawn)
	
	var mod := AutoAttackModifier.new()
	mod.id = "Chicken Shield Stack"
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		var target: Entity = target.get_target(TargetComponent.TargettingStrategy.RANDOM_HERO_ALLY)
		if target == null or target.is_queued_for_deletion(): return
		alterations.inflict_condition_stacks(target, _shield_per_attack, Alteration.Type.SHIELD, "Chicken")
		
	auto_attack_modifier_registry.register_modifier(mod)
	

	
	super._ready()
