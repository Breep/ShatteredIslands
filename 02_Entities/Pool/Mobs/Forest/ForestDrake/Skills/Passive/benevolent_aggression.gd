class_name SE_BenevolentAggression
extends SkillEffect

@export var _proc_chance: float = 20.0
@export var _ap_heal_ration: float = 1.0
var _owner: Entity

func apply(ctx: SkillContext) -> void:
	_owner = ctx.entity
	#_owner.spawn_manager.entity_spawned.connect(_on_entity_spawned) # TODO this (spawn_manager == null)


func _on_entity_spawned(entity: Entity) -> void:
	if not is_instance_valid(entity): return
	if entity.team != _owner.team: return
	var mod:= AutoAttackModifier.new()
	mod.id = &"BenevolentAggression"
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if _owner == null or is_instance_valid(_owner): return
		if not Utils.is_randomize_modifier_active(_proc_chance, _owner.battle_id): return
		if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
		var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
		if not is_instance_valid(target) or target.is_queued_for_deletion(): return
		if not is_instance_valid(entity) or entity == null: return
		entity.heal.take(_ap_heal_ration * _owner.stats.attack_power, false, &"Benevolent Aggression")
	entity.auto_attack_modifier_registry.register_modifier(mod)
