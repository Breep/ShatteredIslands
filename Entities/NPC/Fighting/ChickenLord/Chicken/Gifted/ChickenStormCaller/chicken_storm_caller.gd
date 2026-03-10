class_name ChickenStormCaller
extends ChickenGifted

var _crit_chance: float
var _crit_mult: float

func init(crit_chance: float, crit_mult: float) -> Summon:
	_crit_chance = crit_chance
	_crit_mult = crit_mult
	return self


func _ready() -> void:
	
	var mod := StatModifier.new()
	mod.id = &"Chicken_Storm_caller_crit_multi"
	mod.stat_type = EntityStats.StatType.CRIT_MULT
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _crit_mult
	mod.tags = []
	stat_modifiers_registry.register_modifier(mod)
	
	var mod2 := StatModifier.new()
	mod2.id = &"Chicken_Storm_caller_crit_chance"
	mod2.stat_type = EntityStats.StatType.CRIT_CHANCE
	mod2.calc_type = StatModifier.CalcType.ADD
	mod2.value = _crit_chance
	mod2.tags = []
	stat_modifiers_registry.register_modifier(mod2)
	
	var mod3 := StatModifier.new()
	mod3.id = &"Chicken_Storm_caller_first_hit_crit"
	mod3.stat_type = EntityStats.StatType.CRIT_CHANCE
	mod3.calc_type = StatModifier.CalcType.ADD
	mod3.value = 100
	mod3.tags = []
	stat_modifiers_registry.register_modifier(mod3)
	
	var mod4 := AutoAttackModifier.new()
	mod4.id = &"First_hit_Crit_Storm_Caller_Chicken"
	mod4.is_one_time_effect = true
	mod4.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		stat_modifiers_registry.unregister_modifier(mod3)
	auto_attack_modifier_registry.register_modifier(mod4)
	
	super._ready()
	
