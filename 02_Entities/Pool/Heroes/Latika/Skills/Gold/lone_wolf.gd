class_name SE_LoneWolf
extends SkillEffect

# Talent Gold "Loup Solitaire" : tant qu'aucun allié n'est à moins de _isolation_radius m,
# Latika gagne +_damage_percent % de dégâts (M_POWER) et +_crit_percent % de chance de
# crit. Les bonus sont retirés dès qu'un allié entre dans le rayon. Sniper isolée.

const POWER_MOD_ID := &"LoneWolfPower"
const CRIT_MOD_ID := &"LoneWolfCrit"

@export var _damage_percent: float = 25.0
@export var _crit_percent: float = 20.0
@export var _isolation_radius: float = 3.0
## Période (s) du check de proximité.
@export var _check_period: float = 0.5

const _POWER_ACTIONS: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
]


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_LoneWolf: null owner", Verbose.Category.ENTITY_MODULE)
		return

	# Boxed pour vivre par instance (la resource SkillEffect peut être partagée).
	var applied: Array[bool] = [false]
	var check := func() -> void:
		var isolated: bool = latika.target.get_targets(
			TargetComponent.MultipleTargettingStrategy.ALLIES, _isolation_radius).is_empty()
		if isolated and not applied[0]:
			_apply_bonus(latika)
			applied[0] = true
		elif not isolated and applied[0]:
			_remove_bonus(latika)
			applied[0] = false
	latika.battle_callback_registry.register_periodic(&"LoneWolfCheck", _check_period, check)


func _apply_bonus(latika: Entity) -> void:
	for action_type: Utils.ActionType in _POWER_ACTIONS:
		var power := StatModifier.new()
		power.id = POWER_MOD_ID
		power.stat_type = EntityStats.StatType.M_POWER
		power.action_type = action_type
		power.value = _damage_percent
		latika.stat_modifiers_registry.register_modifier(power)
	var crit := StatModifier.new()
	crit.id = CRIT_MOD_ID
	crit.stat_type = EntityStats.StatType.CRIT_CHANCE
	crit.value = _crit_percent
	latika.stat_modifiers_registry.register_modifier(crit)


func _remove_bonus(latika: Entity) -> void:
	for action_type: Utils.ActionType in _POWER_ACTIONS:
		latika.stat_modifiers_registry.remove_modifier(
			EntityStats.StatType.M_POWER, POWER_MOD_ID, action_type)
	latika.stat_modifiers_registry.remove_modifier(EntityStats.StatType.CRIT_CHANCE, CRIT_MOD_ID)
