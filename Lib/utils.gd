extends Node

# ============================== Enums ==============================
#region Enums
enum ActionType {
	DAMAGE_PHYSICAL,
	DAMAGE_MAGICAL,
	DAMAGE_POISON,
	DAMAGE_PURE,
	UTILITY_HEAL,
	UTILITY_CLEANSE,
	UTILITY_DISPELL,
	STACK_SHIELD,
	STACK_IGNITE,
	STACK_POISON,
	STACK_REGEN,
	STACK_NECROSIS,
	STATUS_STUN,
	STATUS_TAUNT,
	STATUS_SILENCE,
	STATUS_INVULNERABLE,
	STATUS_UNTARGETABLE,
}

enum ActionCategory {
	DAMAGE,
	HEAL,
	STACK,
	STATUS,
	UTILITY,
	DODGE,
}

enum PercentModifier {
	MAX_HP,
	CURRENT_HP,
	LOST_HP,
}
#endregion

# ============================== Constants ==============================
const DAMAGE_COLORS: Dictionary[ActionType, Color] = {
	ActionType.DAMAGE_PHYSICAL: Color.WHITE,
	ActionType.DAMAGE_MAGICAL: Color.DARK_BLUE,
	ActionType.DAMAGE_PURE: Color.DARK_GOLDENROD,
	ActionType.DAMAGE_POISON: Color.WEB_GREEN,
	ActionType.UTILITY_HEAL: Color.AQUAMARINE
}
#endregion

# ============================== Public variables ==============================

# ============================== Private variables ==============================

var _battle_rngs: Dictionary[int, RandomNumberGenerator] = {}
var _global_rng := RandomNumberGenerator.new()

# ============================== Node base functions ==============================

func _ready() -> void:
	_global_rng.randomize()

# ============================== Public functions ==============================
#region ===== ACTIONS
func status_to_action(status_type: Status.Type) -> ActionType:
	match status_type:
		Status.Type.STUN: return ActionType.STATUS_STUN
		Status.Type.TAUNT: return ActionType.STATUS_TAUNT
		Status.Type.SILENCE: return ActionType.STATUS_SILENCE
		Status.Type.INVULNERABLE: return ActionType.STATUS_INVULNERABLE
		Status.Type.UNTARGETABLE: return ActionType.STATUS_UNTARGETABLE
		_: return ActionType.STATUS_STUN


func get_all_actions() -> Array[ActionType]:
	return [
		ActionType.DAMAGE_PHYSICAL,
		ActionType.DAMAGE_MAGICAL,
		ActionType.DAMAGE_POISON,
		ActionType.DAMAGE_PURE,
		ActionType.UTILITY_HEAL,
		ActionType.UTILITY_CLEANSE,
		ActionType.UTILITY_DISPELL,
		ActionType.STACK_SHIELD,
		ActionType.STACK_IGNITE,
		ActionType.STACK_POISON,
		ActionType.STACK_REGEN,
		ActionType.STACK_NECROSIS,
		ActionType.STATUS_STUN,
		ActionType.STATUS_TAUNT,
		ActionType.STATUS_SILENCE,
		ActionType.STATUS_INVULNERABLE,
		ActionType.STATUS_UNTARGETABLE,
	]


static func get_action_category(action_type: ActionType) -> ActionCategory:
	match action_type:
		ActionType.DAMAGE_PHYSICAL, ActionType.DAMAGE_MAGICAL, \
		ActionType.DAMAGE_POISON, ActionType.DAMAGE_PURE:
			return ActionCategory.DAMAGE
		ActionType.UTILITY_HEAL:
			return ActionCategory.HEAL
		ActionType.UTILITY_CLEANSE, ActionType.UTILITY_DISPELL:
			return ActionCategory.UTILITY
		ActionType.STACK_SHIELD, ActionType.STACK_IGNITE, \
		ActionType.STACK_POISON, ActionType.STACK_REGEN, ActionType.STACK_NECROSIS:
			return ActionCategory.STACK
		ActionType.STATUS_STUN, ActionType.STATUS_TAUNT, \
		ActionType.STATUS_SILENCE, ActionType.STATUS_INVULNERABLE, ActionType.STATUS_UNTARGETABLE:
			return ActionCategory.STATUS
		_:
			return ActionCategory.UTILITY
#endregion

func create_perpetual_timer(node: Node, wait_time: float, callback: Callable, autostart: bool = false) -> Timer:
	var timer := Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	node.add_child(timer)
	timer.timeout.connect(callback)
	if autostart:
		timer.start()
	return timer


func create_one_shot_timer(node: Node, wait_time: float, callback: Callable, autostart: bool = false) -> Timer:
	var timer := Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	node.add_child(timer)
	timer.timeout.connect(callback)
	timer.timeout.connect(func(): timer.queue_free())
	if autostart:
		timer.start()
	return timer


#region ===== RNG
func register_battle_rng(battle_id: int, seed_value: int) -> void:
	var battle_rng := RandomNumberGenerator.new()
	battle_rng.seed = seed_value
	_battle_rngs[battle_id] = battle_rng


func unregister_battle_rng(battle_id: int) -> void:
	_battle_rngs.erase(battle_id)


func is_randomize_modifier_active(chance_in_percent: float, battle_id: int = -1, id: String = "") -> bool:
	var r = _get_rng(battle_id).randf_range(0, 100)
	Verbose.trace("Rand[" + str(battle_id) + "] " + str(r).pad_decimals(5) + " '" + id + "'", Verbose.Category.DEFAULT)
	return r <= chance_in_percent


func pick_random(array: Array, battle_id: int = -1, id: String = "") -> Variant:
	if array.is_empty(): return null
	var r = _get_rng(battle_id).randi_range(0, array.size() - 1)
	Verbose.trace("Rand[" + str(battle_id) + "] " + str(r) + " '" + id + "'", Verbose.Category.DEFAULT)
	return array[r]


func get_randf_range(p_min: float, p_max: float, battle_id: int = -1, id: String = "") -> float:
	var r: float = _get_rng(battle_id).randf_range(p_min, p_max)
	Verbose.trace("Rand[" + str(battle_id) + "] " + str(r).pad_decimals(5) + " '" + id + "'", Verbose.Category.DEFAULT)
	return r


func get_randi_range(p_min: int, p_max: int, battle_id: int = -1, id: String = "") -> int:
	var r: int = _get_rng(battle_id).randi_range(p_min, p_max)
	Verbose.trace("Rand[" + str(battle_id) + "] " + str(r) + " '" + id + "'", Verbose.Category.DEFAULT)
	return r
#endregion


func recursive_hide(node: Node3D):
	for child in node.get_children():
		if child is Node3D:
			recursive_hide(child)
	if node is Node3D:
		node.hide()


func recursive_show(node: Node3D):
	for child in node.get_children():
		if child is Node3D:
			recursive_show(child)
	if node is Node3D:
		node.show()


func _get_rng(battle_id: int = -1) -> RandomNumberGenerator:
	if battle_id >= 0 and _battle_rngs.has(battle_id):
		return _battle_rngs[battle_id]
	return _global_rng
