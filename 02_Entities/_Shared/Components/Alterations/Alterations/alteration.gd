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
	Type.IGNITE: Color.ORANGE_RED,
	Type.SHIELD: Color.YELLOW,
	Type.REGEN: Color.AQUAMARINE,
	Type.NECROSIS: Color.REBECCA_PURPLE,
	Type.DEFENSE: Color.STEEL_BLUE,
	Type.BLOCK: Color.WHITE_SMOKE,
	Type.THORN: Color.SADDLE_BROWN,
	Type.STRENGTH: Color.ORANGE,
	Type.WEAKNESS: Color.SLATE_GRAY,
	Type.VULNERABILITY: Color.MEDIUM_ORCHID,
	Type.STUN: Color.GOLD,
	Type.SILENCE: Color.DIM_GRAY,
	Type.TAUNT: Color.CRIMSON,
	Type.INVULNERABLE: Color.GOLD,
	Type.UNTARGETABLE: Color.LAVENDER,
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

enum DisplayMode {
	DEFAULT,
	CUSTOM,
	BOTH
}

var type: Type
var id: StringName
var polarity: Polarity = Polarity.BUFF
## If false, re-applying the alteration does not accumulate (semantics defined by subclass).
var stackable: bool = true

## UI presentation — icon shown in the entity info panel; display_color tints
## the stack count label. Concrete subclasses set these in `_init()`.
var icon: Texture2D
var display_color: Color = Color.WHITE
var display_mode: DisplayMode = DisplayMode.DEFAULT

## Tint applied as `modulate` on the icon texture in AlterationIcon.
## `icon_modulate` carries the hue and alpha; `icon_intensity` scales the RGB
## channels (> 1 brightens, < 1 darkens) while leaving alpha untouched.
## Concrete subclasses may override these in `_init()`.
var icon_modulate: Color = Color.WHITE
var icon_intensity: float = 1.0

var _owner: Entity


func bind(owner: Entity) -> void:
	_owner = owner


const ICON_CONFIG_PATH: String = "res://02_Entities/_Shared/Components/Alterations/AlterationIcon/alteration_icon_config.tres"

static var _icon_config: AlterationIconConfig
static var _icon_config_loaded: bool = false


## Lazily-loaded per-type modulate overrides authored via the AlterationIcon
## proto. Returns null when no config has been saved yet.
static func get_icon_config() -> AlterationIconConfig:
	if not _icon_config_loaded:
		_icon_config_loaded = true
		if ResourceLoader.exists(ICON_CONFIG_PATH):
			_icon_config = load(ICON_CONFIG_PATH)
	return _icon_config


## Force the next get_icon_config() to re-read from disk (used by the proto
## right after saving).
static func reload_icon_config() -> void:
	_icon_config = null
	_icon_config_loaded = false


## Final icon tint: base modulate (or saved override) with RGB scaled by
## intensity, alpha preserved.
func get_icon_modulate() -> Color:
	var color: Color = icon_modulate
	var intensity: float = icon_intensity
	var cfg: AlterationIconConfig = get_icon_config()
	if cfg != null and cfg.has_override(type):
		color = cfg.get_color(type)
		intensity = cfg.get_intensity(type)
	return Color(color.r * intensity, color.g * intensity, color.b * intensity, color.a)


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
