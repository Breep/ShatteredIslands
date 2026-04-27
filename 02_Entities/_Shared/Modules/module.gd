class_name Module
extends Node

enum ModuleType {
	MOVEMENT = 0,
	TARGET = 1,
	ALTERATIONS = 2,
	AUTO_ATTACK_PERIODIC_MODULE = 3,
	DAMAGE = 4,
	HEAL = 5,
	ACTION_SENDER_ADD_STACK = 6,
	ACTION_SENDER_REMOVE_STACK = 7,
	ACTION_SENDER_PROJECTILE = 8,
	ACTION_SENDER_SPELL = 9,
	ACTION_SENDER_SUMMON = 10,
	ACTION_SENDER_AUTO_ATTACK = 11,
	ACTION_SENDER_STATUS = 12,
	# 13, 14 reserved (formerly ACTION_RECEIVER_DAMAGE, ACTION_RECEIVER_HEAL — fused into DAMAGE/HEAL)
	ACTION_RECEIVER_ADD_STACK = 15,
	ACTION_RECEIVER_REMOVE_STACK = 16,
	ACTION_RECEIVER_STATUS = 17,
	LABEL_POPUP_MODULE = 18,
}

@export var _owner: Entity # Owner of the module

func init(entity_owner: Entity) -> Module:
	_owner = entity_owner
	return self

func _ready() -> void:
	if _owner == null:
		printerr("Module: undef source [", get_path(), "]")
