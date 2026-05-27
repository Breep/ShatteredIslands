class_name AegisBlade
extends Entity


func _init() -> void:
	super._init()
	category = Category.SUMMON

enum Modifier {
	AD,
	AS,
	SHIELD_AD_MAX,
	SHIELD_AD_TAU,
	DAMAGE_AS_SHIELD
}

const ON_SPAWN_SHIELD: int = 2000

var _spawn_attack_damage: float
var _spawn_attack_speed: float
var _shield_ad_max: float  # Valeur max d'AD apportée par le shield du héro (asymptote)
var _shield_ad_tau: float  # Montée : shield nécessaire pour atteindre ~63% du max
var _damage_as_shield_ratio: float # % of sword AD converted as hero shield

func init(attack_damage: float, attack_speed: float, shield_ad_max: float, shield_ad_tau: float, damage_as_shield_ratio: float) -> AegisBlade:
	_spawn_attack_damage = attack_damage
	_spawn_attack_speed = attack_speed
	_shield_ad_max = shield_ad_max
	_shield_ad_tau = shield_ad_tau
	_damage_as_shield_ratio = damage_as_shield_ratio
	return self


func _ready() -> void:
	alterations.take_condition_stacks(ON_SPAWN_SHIELD, Alteration.Type.SHIELD, false, "Initial Shield")
	#_base_stats.reset_from_self()
	
	_on_summoner_conditions_shield_stacks_changed(summoner.alterations.shield_stacks)
	summoner.alterations.shield_stacks_changed.connect(_on_summoner_conditions_shield_stacks_changed)
	
	var aa_mod := AutoAttackModifier.new()
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not is_instance_valid(summoner): return
		var damage_done: float = cb_vars.get(AutoAttackModifier.VarType.DAMAGE, 0)
		alterations.inflict_condition_stacks(summoner, damage_done * _damage_as_shield_ratio, Alteration.Type.SHIELD, "Aegis Blade")
	auto_attack_modifier_registry.register_modifier(aa_mod)
	
	#_base_stats.attack_damage = _spawn_attack_damage
	#_base_stats.attack_speed = _spawn_attack_speed
	stat_modifiers_registry.recompute_all()
	
	super._ready()


func _on_summoner_conditions_shield_stacks_changed(shield_stack: float) -> void:
	var mod := StatModifier.new()
	mod.value = _shield_ad_max * (1.0 - exp(-shield_stack / _shield_ad_tau)) if _shield_ad_tau > 0.0 else _shield_ad_max
	mod.calc_type = StatModifier.CalcType.ADD
	mod.id = "Shield Transfert"
	mod.stat_type = EntityStats.StatType.AD
	stat_modifiers_registry.register_modifier(mod)
