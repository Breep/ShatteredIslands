class_name Alteration
extends Resource

## Base class for every alteration (stack / timed / state).
## Each concrete alteration knows its owning Entity (via bind) and runs its own
## process_tick() — AlterationsModule simply iterates the registered instances.

const TICKS_PER_SECOND: int = 60
const TICK_DELTA: float = 1.0 / TICKS_PER_SECOND

enum Type {
	# StackAlteration (float stacks)
	POISON,
	IGNITE,
	SHIELD,
	REGEN,
	NECROSIS,
	DEFENSE,
	BLOCK,
	THORN,
	STRENGTH,
	WEAKNESS,
	VULNERABILITY,
	# TimedAlteration (float time remaining)
	STUN,
	SILENCE,
	# StateAlteration (boolean on/off — no timer)
	TAUNT,
	INVULNERABLE,
	UNTARGETABLE,
}

enum Polarity { BUFF, DEBUFF }

## Keys for the `mod` dict passed to add_stack/apply.
enum ModifierType {
	DURATION,    # batch-expiration window for ring-buffer stacks (Regen)
	ACTION_TYPE, # per-ActionType dispatch for typed stacks (Strength/Weakness/Vulnerability)
}

const STACK_TYPES: Array[Type] = [
	Type.POISON, Type.IGNITE, Type.SHIELD, Type.REGEN, Type.NECROSIS,
	Type.DEFENSE, Type.BLOCK, Type.THORN,
	Type.STRENGTH, Type.WEAKNESS, Type.VULNERABILITY,
]

const TIMED_TYPES: Array[Type] = [
	Type.STUN, Type.SILENCE,
]

const STATE_TYPES: Array[Type] = [
	Type.TAUNT, Type.INVULNERABLE, Type.UNTARGETABLE,
]

const NEGATIVE_TYPES: Array[Type] = [
	Type.POISON, Type.IGNITE, Type.NECROSIS,
	Type.WEAKNESS, Type.VULNERABILITY,
	Type.STUN, Type.SILENCE,
	Type.TAUNT,
]

const TYPE_COLORS: Dictionary[Type, Color] = {
	Type.POISON: Color.WEB_GREEN,
	Type.IGNITE: Color.DARK_RED,
	Type.SHIELD: Color.YELLOW,
	Type.REGEN: Color.AQUAMARINE,
	Type.NECROSIS: Color.REBECCA_PURPLE,
}

const TYPE_TO_ACTION: Dictionary[Type, int] = {
	Type.POISON: Utils.ActionType.STACK_POISON,
	Type.IGNITE: Utils.ActionType.STACK_IGNITE,
	Type.SHIELD: Utils.ActionType.STACK_SHIELD,
	Type.REGEN: Utils.ActionType.STACK_REGEN,
	Type.NECROSIS: Utils.ActionType.STACK_NECROSIS,
	Type.STUN: Utils.ActionType.STATUS_STUN,
	Type.TAUNT: Utils.ActionType.STATUS_TAUNT,
	Type.SILENCE: Utils.ActionType.STATUS_SILENCE,
	Type.INVULNERABLE: Utils.ActionType.STATUS_INVULNERABLE,
	Type.UNTARGETABLE: Utils.ActionType.STATUS_UNTARGETABLE,
}

@export var type: Type
@export var id: StringName
@export var polarity: Polarity = Polarity.BUFF
## If false, re-applying the alteration does not accumulate (semantics defined by subclass).
@export var stackable: bool = true

var _owner: Entity


func bind(owner: Entity) -> void:
	_owner = owner


## Called when the alteration is registered with an AlterationsModule.
func _on_added() -> void:
	pass


## Called when the alteration is cleared / expired / removed.
func _on_removed() -> void:
	pass


## Called every physics tick by AlterationsModule.process_tick().
func process_tick() -> void:
	pass


static func is_stack_type(alteration_type: Type) -> bool:
	return alteration_type in STACK_TYPES


static func is_timed_type(alteration_type: Type) -> bool:
	return alteration_type in TIMED_TYPES


static func is_state_type(alteration_type: Type) -> bool:
	return alteration_type in STATE_TYPES


static func is_negative(alteration_type: Type) -> bool:
	return alteration_type in NEGATIVE_TYPES


static func to_action(alteration_type: Type) -> Utils.ActionType:
	return TYPE_TO_ACTION.get(alteration_type, Utils.ActionType.STACK_POISON)


static func get_color(alteration_type: Type) -> Color:
	return TYPE_COLORS.get(alteration_type, Color.WHITE)
