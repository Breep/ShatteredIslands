class_name SE_WoundedFury
extends SkillEffect

@export var _stat_bonus_per_hp_missing_percent: float = 1.0
@export var _stat_type: EntityStats.StatType = EntityStats.StatType.AS

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	
	var mod := StatModifier.new()
	mod.id = &"Wounded Fury"
	mod.stat_type = _stat_type
	
	var missing_hp_percent: float = (_owner.stats.health_max - _owner.stats.health) / _owner.stats.health_max
	if _stat_type == EntityStats.StatType.AS:
		mod.value = _stat_bonus_per_hp_missing_percent * missing_hp_percent
	else:
		mod.value = _stat_bonus_per_hp_missing_percent * missing_hp_percent * 100
	_owner.stat_modifiers_registry.register_modifier(mod)
	
	_owner.stats.health_changed.connect(func(_unused)-> void:
		var missing_hp_percent2: float = (_owner.stats.health_max - _owner.stats.health) / _owner.stats.health_max
		if _stat_type == EntityStats.StatType.AS:
			mod.value = _stat_bonus_per_hp_missing_percent * missing_hp_percent2
		else:
			mod.value = _stat_bonus_per_hp_missing_percent * missing_hp_percent2 * 100 
		_owner.stat_modifiers_registry.register_modifier(mod)
		)


func get_description() -> String:
	var max_bonus: float = _stat_bonus_per_hp_missing_percent
	if _stat_type != EntityStats.StatType.AS:
		max_bonus *= 100.0
	return "Convertit ses PV manquants en bonus de " + _stat_label() + " : plus il " \
		+ "est blessé, plus le bonus grandit, jusqu'à " + _value(max_bonus) + " à l'agonie."


func _stat_label() -> String:
	match _stat_type:
		EntityStats.StatType.AS: return "vitesse d'attaque"
		EntityStats.StatType.AD: return "[[WARRIOR]]"
		EntityStats.StatType.AP: return "puissance magique"
		_: return "statistique"
	
	
