class_name BattleLog
extends Resource

enum Type {
	AUTO_ATTACK,
	DAMAGE_TAKEN,
	SPELL_CASTED,
	STACK_TAKEN,
	ACTION_DONE,
}

enum Modifier {
	CRITICAL,
	POISON,
	IGNITE,
	INSTABILITY,
	ARMOR
}

enum Main {
	TIME,
	ACTION_TYPE,
	ACTION_ID,
	VALUE,
	CRITICAL,
	TYPE,
	SOURCE,
	TARGET,
	MODIFIER,
	DAMAGE,
	DAMAGE_TYPE,
	SPELL_TYPE,
	STACK_TYPE,
	STACK_NUMBER
}

const TIME: String = "time"
const TYPE: String = "type"
const SOURCE: String = "source"
const TARGET: String = "target"
const MODIFIER: String = "Modifier"
