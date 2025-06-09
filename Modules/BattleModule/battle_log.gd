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

const TIME: String = "time"
const TYPE: String = "type"
const SOURCE: String = "source"
const TARGET: String = "target"
const MODIFIER: String = "Modifier"
