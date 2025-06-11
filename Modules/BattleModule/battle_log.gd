class_name BattleLog
extends Node

enum Type {
	AUTO_ATTACK
}

enum Modifier {
	CRITICAL,
	POISON,
	IGNITE,
	INSTABILITY
}

enum Main {
	TIME,
	TYPE,
	SOURCE,
	TARGET,
	MODIFIER
}

const TIME: String = "time"
const TYPE: String = "type"
const SOURCE: String = "source"
const TARGET: String = "target"
const MODIFIER: String = "Modifier"


@rpc("authority", "call_remote", "reliable")
func send_battle_log(log: Array[Dictionary]) -> void:
	pass
