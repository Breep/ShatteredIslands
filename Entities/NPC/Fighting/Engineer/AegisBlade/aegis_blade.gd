class_name AegisBlade
extends Summon

enum Modifier {
	AS,
	SHIELD_AS_AD,
	DAMAGE_AS_SHIELD
}

const ON_SPAWN_SHIELD: int = 2000

var _spawn_attack_speed: float
var _shield_as_ad_ratio: float # % of hero shield converted as sword AD
var _damage_as_shield_ratio: float # % of sword AD converted as hero shield

func init(attack_speed: float, shield_as_ad_ratio: float, damage_as_shield_ratio: float) -> AegisBlade:
	_spawn_attack_speed = attack_speed
	_shield_as_ad_ratio = shield_as_ad_ratio
	_damage_as_shield_ratio = damage_as_shield_ratio
	return self


func _ready() -> void:
	take_condition_stacks(ON_SPAWN_SHIELD, Stack.Type.SHIELD, false, "Initial Shield")
	_base_stats.reset_from_self()
	
	_on_summoner_conditions_shield_stacks_changed(summoner.conditions.shield_stacks)
	summoner.conditions.shield_stacks_changed.connect(_on_summoner_conditions_shield_stacks_changed)
	
	var aa_mod := AutoAttackModifier.new()
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not is_instance_valid(summoner): return
		var damage_done: float = cb_vars.get(AutoAttackModifier.VarType.DAMAGE, 0)
		inflict_condition_stacks(summoner, damage_done * _damage_as_shield_ratio, Stack.Type.SHIELD, "Aegis Blade")
	auto_attack_modifier_registry.register_modifier(aa_mod)
	
	super._ready()


func _on_summoner_conditions_shield_stacks_changed(shield_stack: float) -> void:
	var mod := StatModifier.new()
	mod.value = shield_stack * _shield_as_ad_ratio
	mod.calc_type = StatModifier.CalcType.ADD
	mod.id = "Shield Transfert"
	mod.stat_type = EntityStats.StatType.AD
	stat_modifiers_registry.register_modifier(mod)
