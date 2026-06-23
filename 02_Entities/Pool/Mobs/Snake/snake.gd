class_name Snake
extends Entity


func _init() -> void:
	super._init()
	category = Category.SUMMON

func _ready() -> void:
	var mod := AutoAttackModifier.new()
	mod.id = "Snake Poison"
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
		var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
		if target == null or target.is_queued_for_deletion(): return
		alterations.direct_stack(target, 1, Alteration.Type.POISON, "Snake")
		
	auto_attack_modifier_registry.register_modifier(mod)
	super._ready()
	
