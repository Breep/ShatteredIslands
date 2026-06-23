class_name ChickenPoison
extends ChickenGifted

var _poison_stack_ratio: float
var _stacks_number: int

func init(poison_stack_ratio: float, stacks_number: int) -> Entity:
	_poison_stack_ratio = poison_stack_ratio
	_stacks_number = stacks_number
	return self

func _ready() -> void:
	var mod := AutoAttackModifier.new()
	mod.id = "Chicken Poison Stack"
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
		var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
		if target == null or target.is_queued_for_deletion(): return
		if Utils.is_randomize_modifier_active(_poison_stack_ratio*100, battle_id):
			alterations.direct_stack(target, _stacks_number, Alteration.Type.POISON, "Chicken")
		
	auto_attack_modifier_registry.register_modifier(mod)
	super._ready()
	
