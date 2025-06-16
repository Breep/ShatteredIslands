class_name BattleLog
extends Resource

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
