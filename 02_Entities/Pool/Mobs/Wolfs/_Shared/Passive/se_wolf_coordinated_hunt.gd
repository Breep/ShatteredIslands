class_name SE_WolfCoordinatedHunt
extends SkillEffect

# Passif partagé des loups de Latika "Traque Coordonnée" : le loup synergise avec la
# cible marquée par sa maîtresse (cf. SE_PackLeader). Tant qu'il fonce vers cette cible
# il gagne de la vitesse de déplacement ; tant qu'il la frappe il gagne des dégâts et de
# la résistance. Tous les bonus sont des self-buffs (M_POWER / M_RESISTANCE / MS),
# togglés par un check périodique — aucune plomberie de dégâts par-source nécessaire.

const MS_MOD_ID := &"WolfHuntMs"
const POWER_MOD_ID := &"WolfHuntPower"
const RESIST_MOD_ID := &"WolfHuntResist"

@export var _ms_percent: float = 30.0
@export var _damage_percent: float = 20.0
@export var _resist_percent: float = 20.0
## Période (s) du check d'engagement sur la cible marquée.
@export var _check_period: float = 0.3

const _DAMAGE_ACTIONS: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
]


func apply(ctx: SkillContext) -> void:
	var wolf: Entity = ctx.entity
	if wolf == null:
		Verbose.error("SE_WolfCoordinatedHunt: null owner", Verbose.Category.ENTITY_MODULE)
		return

	# Boxed pour vivre par instance (la resource SkillEffect peut être partagée).
	var ms_on: Array[bool] = [false]
	var combat_on: Array[bool] = [false]

	var check := func() -> void:
		var marked: Entity = _marked_target(wolf)
		var engaging: bool = is_instance_valid(marked) and wolf.auto_attack != null \
			and wolf.auto_attack.get_current_target() == marked
		var attacking: bool = engaging and wolf.is_target_in_attack_range(marked)
		var chasing: bool = engaging and not attacking and wolf.is_moving
		_set_ms(wolf, chasing, ms_on)
		_set_combat(wolf, attacking, combat_on)
	wolf.battle_callback_registry.register_periodic(&"WolfCoordinatedHunt", _check_period, check)


func get_description() -> String:
	return "Quand il fonce vers la cible marquée par Latika, gagne +" + _value(_ms_percent) \
		+ "% de vitesse de déplacement. Tant qu'il l'attaque, gagne +" + _value(_damage_percent) \
		+ "% de dégâts et +" + _value(_resist_percent) + "% de réduction de dégâts."


# Cible courante marquée par Latika (la maîtresse est le summoner du loup).
func _marked_target(wolf: Entity) -> Entity:
	return SE_PackLeader.get_marked_target(wolf.summoner)


func _set_ms(wolf: Entity, active: bool, state: Array[bool]) -> void:
	if active == state[0]:
		return
	state[0] = active
	if active:
		var ms := StatModifier.new()
		ms.id = MS_MOD_ID
		ms.stat_type = EntityStats.StatType.MS
		ms.calc_type = StatModifier.CalcType.MULT
		ms.value = _ms_percent / 100.0
		wolf.stat_modifiers_registry.register_modifier(ms)
	else:
		wolf.stat_modifiers_registry.remove_modifier(EntityStats.StatType.MS, MS_MOD_ID)


func _set_combat(wolf: Entity, active: bool, state: Array[bool]) -> void:
	if active == state[0]:
		return
	state[0] = active
	if active:
		for action_type: Utils.ActionType in _DAMAGE_ACTIONS:
			var power := StatModifier.new()
			power.id = POWER_MOD_ID
			power.stat_type = EntityStats.StatType.M_POWER
			power.action_type = action_type
			power.value = _damage_percent
			wolf.stat_modifiers_registry.register_modifier(power)
			var resist := StatModifier.new()
			resist.id = RESIST_MOD_ID
			resist.stat_type = EntityStats.StatType.M_RESISTANCE
			resist.action_type = action_type
			resist.value = _resist_percent
			wolf.stat_modifiers_registry.register_modifier(resist)
	else:
		for action_type: Utils.ActionType in _DAMAGE_ACTIONS:
			wolf.stat_modifiers_registry.remove_modifier(
				EntityStats.StatType.M_POWER, POWER_MOD_ID, action_type)
			wolf.stat_modifiers_registry.remove_modifier(
				EntityStats.StatType.M_RESISTANCE, RESIST_MOD_ID, action_type)
