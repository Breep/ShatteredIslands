class_name SE_BloodBond
extends SkillEffect

# Talent Gold "Lien du Sang" : recrute à vie deux loups nommés (Geri, Freki) dans le
# roaster du joueur, puis — tant qu'au moins _required_pack_size loups de Latika sont
# vivants — Latika ET ses loups gagnent +_global_as_percent % AS et +_damage_percent %
# dégâts. La meute est retrouvée par un scan de zone au début du combat (filtré sur les
# loups Vrock dont le summoner est Latika), puis le buff est réévalué à chaque mort de loup.

const AS_MOD_ID := &"BloodBondAS"
const POWER_MOD_ID := &"BloodBondPower"
# Source de roaster des loups recrutés : sert de garde d'idempotence (Latika est
# réinstanciée à chaque combat/taverne et rejoue apply(), mais le roaster persiste).
const PACK_SOURCE := &"BloodBondPack"

@export var _required_pack_size: int = 3
@export var _global_as_percent: float = 20.0
@export var _damage_percent: float = 25.0
## Loups recrutés à vie dans le roaster quand le joueur tranche ce talent (Geri, Freki).
@export var _recruited_pack: Array[EntityDesc] = []

const _POWER_ACTIONS: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
]


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_BloodBond: null owner", Verbose.Category.ENTITY_MODULE)
		return

	_recruit_pack(ctx.roaster)

	# Boxed pour vivre par instance (la resource SkillEffect peut être partagée).
	var pack: Array[Entity] = []
	var active: Array[bool] = [false]

	var evaluate := func() -> void:
		var alive: int = 0
		for wolf: Entity in pack:
			if is_instance_valid(wolf) and not wolf.is_dead():
				alive += 1
		var should_be_active: bool = alive >= _required_pack_size
		if should_be_active == active[0]:
			return
		active[0] = should_be_active
		if should_be_active:
			_apply_buff(latika, pack)
		else:
			_remove_buff(latika, pack)

	var on_battle_start := func() -> void:
		pack.assign(_scan_pack(latika))
		for wolf: Entity in pack:
			if is_instance_valid(wolf):
				wolf.died.connect(func(_self_ref: Entity) -> void: evaluate.call())
		evaluate.call()
	latika.battle_callback_registry.register_battle_start(&"BloodBondScan", on_battle_start)


func get_description() -> String:
	return "Geri et Freki rejoignent définitivement la meute. Tant qu'au moins " \
		+ _value(_required_pack_size) + " loups sont en vie, Latika et ses loups gagnent +" \
		+ _value(_global_as_percent) + "% de vitesse d'attaque et +" \
		+ _value(_damage_percent) + "% de dégâts."


# Recrute la meute nommée dans le roaster du joueur. Idempotent : Latika rejoue apply()
# à chaque (ré)apparition, mais le roaster persiste — la présence d'entries marquées
# PACK_SOURCE signale un recrutement déjà fait, on ne double pas.
func _recruit_pack(roaster: Roaster) -> void:
	if roaster == null:
		return
	if not roaster.get_by_source(PACK_SOURCE).is_empty():
		return
	for desc: EntityDesc in _recruited_pack:
		roaster.add_acolyte(desc, PACK_SOURCE)


# Retrouve les loups de Latika sur la zone : acolytes Vrock dont le summoner est Latika.
func _scan_pack(latika: Entity) -> Array[Entity]:
	var pack: Array[Entity] = []
	for ally: Entity in latika.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if ally is Vrock and ally.summoner == latika:
			pack.append(ally)
	return pack


func _apply_buff(latika: Entity, pack: Array[Entity]) -> void:
	_buff_entity(latika)
	for wolf: Entity in pack:
		if is_instance_valid(wolf) and not wolf.is_dead():
			_buff_entity(wolf)


func _remove_buff(latika: Entity, pack: Array[Entity]) -> void:
	_unbuff_entity(latika)
	for wolf: Entity in pack:
		_unbuff_entity(wolf)


func _buff_entity(entity: Entity) -> void:
	if not is_instance_valid(entity) or entity.stat_modifiers_registry == null:
		return
	var as_mod := StatModifier.new()
	as_mod.id = AS_MOD_ID
	as_mod.stat_type = EntityStats.StatType.AS
	as_mod.calc_type = StatModifier.CalcType.MULT
	as_mod.value = _global_as_percent / 100.0
	entity.stat_modifiers_registry.register_modifier(as_mod)
	for action_type: Utils.ActionType in _POWER_ACTIONS:
		var power := StatModifier.new()
		power.id = POWER_MOD_ID
		power.stat_type = EntityStats.StatType.M_POWER
		power.action_type = action_type
		power.value = _damage_percent
		entity.stat_modifiers_registry.register_modifier(power)


func _unbuff_entity(entity: Entity) -> void:
	if not is_instance_valid(entity) or entity.stat_modifiers_registry == null:
		return
	entity.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AS, AS_MOD_ID)
	for action_type: Utils.ActionType in _POWER_ACTIONS:
		entity.stat_modifiers_registry.remove_modifier(
			EntityStats.StatType.M_POWER, POWER_MOD_ID, action_type)
