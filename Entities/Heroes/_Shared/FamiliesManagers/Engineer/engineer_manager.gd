class_name EngineerManager
extends FamilyManager

const P_PROTO_SHIELD_SHIELD: Array[int] = [0, 250, 600, 1000, 2000]
const P_PROTO_SHIELD_HP_MAX: Array[int] = [0, 50, 125, 200, 400]

func start() -> void:
	Verbose.debug("EngineerManager start", Verbose.Category.FAMILY_MANAGER)
	if level >= 1:
		_passive_spawn_proto_shield()


func stop() -> void:
	Verbose.debug("EngineerManager stop", Verbose.Category.FAMILY_MANAGER)


func _passive_spawn_proto_shield() -> void:
	var spawn_config := SpawnLocationConfig.create_entity_relative(_owner, 5.0)
	_owner.summon_entity(Entity.EntityType.PROTO_SHIELD, spawn_config, {
		ProtoShield.Modifier.SHIELD: P_PROTO_SHIELD_SHIELD[level],
		ProtoShield.Modifier.HP_MAX: P_PROTO_SHIELD_HP_MAX[level]
	})
