class_name Module
extends Node

enum ModuleType {
	MOVEMENT,
	TARGET,
	CONDITIONS,
	STATUS,
	AUTO_ATTACK_PERIODIC_MODULE,
	ACTION_SENDER_DAMAGE,
	ACTION_SENDER_HEAL,
	ACTION_SENDER_ADD_STACK,
	ACTION_SENDER_REMOVE_STACK,
	ACTION_SENDER_PROJECTILE,
	ACTION_SENDER_SPELL,
	ACTION_SENDER_SUMMON,
	ACTION_SENDER_AUTO_ATTACK,
	ACTION_SENDER_STATUS,
	ACTION_RECEIVER_DAMAGE,
	ACTION_RECEIVER_HEAL,
	ACTION_RECEIVER_ADD_STACK,
	ACTION_RECEIVER_REMOVE_STACK,
	ACTION_RECEIVER_STATUS,
}

@export var _owner: Entity # Owner of the module

func init(entity_owner: Entity) -> Module:
	_owner = entity_owner
	return self

func _ready() -> void:
	if _owner == null:
		printerr("Module: undef source [", get_path(), "]")
