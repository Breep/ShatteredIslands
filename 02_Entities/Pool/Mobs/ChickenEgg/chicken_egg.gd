class_name ChickenEgg
extends Entity


func _init() -> void:
	super._init()
	category = Category.SUMMON

enum Type {
	BASIC,
	GIFTED_ATTACK,
	GIFTED_STORM_CALLER,
	GIFTED_POISON,
	GIFTED_ARDENT_CELESTIAL,
	GIFTED_COLOSSUS,
	GIFTED_LIGHT,
	GIFTED_ENGINEER,
	GIFTED_NECROSIS
}

class Modifier extends RefCounted:
	const HATCH_TIME: StringName = &"Hatch Time"
	const CHICKEN_TYPE: StringName = &"Chicken Type"
	const CHICKEN_MODIFIERS: StringName = &"Chicken Modifiers"
	const HATCH_MODIFIERS: StringName = &"Hatch Modifiers"
	const SCALE: StringName = &"Scale"

var _hatch_time: float
var _chicken_type: Chicken.Type
var _chicken_modifiers: Dictionary
var _hatch_modifiers: Array[HatchModifier]
var _scale: float

func init(hatch_time: float, chicken_type: Chicken.Type, chicken_modifiers: Dictionary, hatch_modifiers: Array[HatchModifier] = [], opt_scale: float = 1) -> ChickenEgg:
	_hatch_time = hatch_time
	_chicken_type = chicken_type
	_chicken_modifiers = chicken_modifiers
	_hatch_modifiers = hatch_modifiers
	_scale = opt_scale
	return self


func _ready() -> void:
	super._ready()
	battle_callback_registry.register_oneshot(_hatch_time, _hatch)
	_visual_3d.set_visual(_chicken_type)
	scale = Vector3(_scale, _scale, _scale)

# ============================== Hatch ==============================

func _hatch() -> void:
	var vars := {
		HatchModifier.VarType.EGG: self,
		HatchModifier.VarType.SUMMONER: summoner,
		HatchModifier.VarType.CHICKEN_TYPE: _chicken_type,
		HatchModifier.VarType.SPAWN_COUNT: 1,
		HatchModifier.VarType.SPAWN_CONFIG: SpawnLocationConfig.create_entity_relative(self, 1),
		HatchModifier.VarType.CHICKEN_MODIFIERS: _chicken_modifiers,
	}
	
	# --- Before hatch ---
	for mod in _hatch_modifiers:
		if mod.before_hatch_callback.is_valid():
			mod.before_hatch_callback.call(vars)

	# --- Spawn chickens via the hero so context transfer stays hero -> chicken ---
	var count: int = vars[HatchModifier.VarType.SPAWN_COUNT]
	var spawn_cfg: SpawnLocationConfig = vars[HatchModifier.VarType.SPAWN_CONFIG]
	var chicken_mods: Dictionary = vars[HatchModifier.VarType.CHICKEN_MODIFIERS]
	
	chicken_mods["Type"] = _chicken_type
	for i in count:
		summoner.summon.summon_entity(Entity.EntityType.CHICKEN, spawn_cfg, chicken_mods)

	# --- After hatch ---
	for mod in _hatch_modifiers:
		if mod.after_hatch_callback.is_valid():
			mod.after_hatch_callback.call(vars)

	# --- Consume one-time modifiers ---
	_hatch_modifiers = _hatch_modifiers.filter(func(m: HatchModifier) -> bool: return not m.is_one_time_effect)

	# --- Despawn egg ---
	despawn.play_despawn_animation()


# ============================== Invincibility ==============================

## The egg ignores all damage — it despawns only after hatching.
func take_damage(_damage: float, _damage_type: Utils.ActionType, _is_critical: bool, _action_id: StringName, _source: Entity = null) -> float:
	return 0.0
