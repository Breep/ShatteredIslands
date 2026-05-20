class_name ChickenLight
extends ChickenGifted

var _regen_stack_ratio: float
var _stacks_number: int
var _heal_strength_inherited

func init(regen_stack_ratio: float, heal_strength_inherited: float) -> Entity:
	_regen_stack_ratio = regen_stack_ratio
	_stacks_number = 10
	_heal_strength_inherited = heal_strength_inherited
	return self

func _ready() -> void:
	
	if alterations != null:
		alterations.add_typed_stack(Alteration.Type.STRENGTH, Utils.ActionType.UTILITY_HEAL, _heal_strength_inherited)
	
	var mod := AutoAttackModifier.new()
	mod.id = "Chicken Regen Stack"
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		var target: Entity = target.get_target(TargetComponent.TargettingStrategy.RANDOM_HERO_ALLY)
		if target == null or target.is_queued_for_deletion(): return
		if Utils.is_randomize_modifier_active(_regen_stack_ratio*100, battle_id):
			alterations.inflict_condition_stacks(target, _stacks_number, Alteration.Type.REGEN, "Chicken")
		
	auto_attack_modifier_registry.register_modifier(mod)
	super._ready()
