class_name EngineerManager
extends FamilyManager

#region ============================== Constants ==============================
const P_PROTO_SHIELD_SHIELD: Array[int] = [0, 350, 700, 980, 1400]
const P_PROTO_SHIELD_HP_MAX: Array[int] = [0, 50, 100, 150, 250]

const P_SHIELD_POWER: Array[int] = [0, 10, 20, 30, 50]
#endregion


#region ============================== Public API ==============================
func start() -> void:
	Verbose.debug("EngineerManager start", Verbose.Category.FAMILY_MANAGER)


func stop() -> void:
	Verbose.debug("EngineerManager stop", Verbose.Category.FAMILY_MANAGER)


func apply_passive() -> void:
	if level >= 1:
		_passive_spawn_proto_shield()
		_passive_set_shield_power()
#endregion


#region ============================== Passive ==============================
func _passive_spawn_proto_shield() -> void:
	_owner.battle_callback_registry.register_battle_start("Engineer passive", func() -> void:
		var spawn_config := SpawnLocationConfig.create_between_center(_owner, 3.0)
		_owner.summon_entity(Entity.EntityType.PROTO_SHIELD, spawn_config, {
			ProtoShield.Modifier.SHIELD: P_PROTO_SHIELD_SHIELD[level],
			ProtoShield.Modifier.HP_MAX: P_PROTO_SHIELD_HP_MAX[level]
		})
	)

func _passive_set_shield_power() -> void:
	var mod := StatModifier.new()
	mod.stat_type = EntityStats.StatType.POWER
	mod.action_type = Utils.ActionType.STACK_SHIELD
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = P_SHIELD_POWER[level]
	mod.id = "Engineer passive"
	_owner.stat_modifiers_registry.register_modifier(mod)
#endregion
