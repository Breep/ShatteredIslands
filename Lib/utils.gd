extends Node

# ============================== Enums ==============================
#region Enums
enum ActionType {
	DAMAGE_PHYSICAL,
	DAMAGE_MAGICAL,
	DAMAGE_POISON,
	DAMAGE_PURE,
	UTILITY_HEAL,
	UTILITY_STUN,
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

enum DamageType {
	PHYSICAL,
	MAGICAL,
	POISON,
	PURE,
	HEAL,
}

enum PercentModifier {
	MAX_HP,
	CURRENT_HP,
	LOST_HP,
}

enum StackType {
	POISON,
	SHIELD,
	IGNITE,
	REGEN,
	NECROSIS
}

enum AttackType {
	UNDEF,
	AUTO_ATTACK
}
#endregion

# ============================== Constants ==============================
#region Constants
const DAMAGE_COLORS: Dictionary[DamageType, Color] = {
	DamageType.PHYSICAL: Color.WHITE,
	DamageType.MAGICAL: Color.DARK_BLUE,
	DamageType.PURE: Color.DARK_GOLDENROD,
	DamageType.POISON: Color.WEB_GREEN,
	DamageType.HEAL: Color.AQUAMARINE
}

const STACK_COLORS: Dictionary[StackType, Color] = {
	StackType.POISON: Color.WEB_GREEN,
	StackType.SHIELD: Color.SADDLE_BROWN,
	StackType.IGNITE: Color.DARK_RED,
	StackType.REGEN: Color.AQUAMARINE,
	StackType.NECROSIS: Color.REBECCA_PURPLE
}
#endregion

# ============================== Public variables ==============================

@onready var rng := RandomNumberGenerator.new()

# ============================== Private variables ==============================

# ============================== Node base functions ==============================

func _ready() -> void:
	rng.randomize()

# ============================== Public functions ==============================
#region ===== ACTIONS
func stack_to_action(stack_type: StackType) -> ActionType:
	match stack_type:
		StackType.POISON: return ActionType.STACK_POISON
		StackType.SHIELD: return ActionType.STACK_SHIELD
		StackType.IGNITE: return ActionType.STACK_IGNITE
		StackType.REGEN: return ActionType.STACK_REGEN
		StackType.NECROSIS: return ActionType.STACK_NECROSIS
		_: return ActionType.STACK_POISON


func damage_to_action(damage_type: DamageType) -> ActionType:
	match damage_type:
		DamageType.PHYSICAL: return ActionType.DAMAGE_PHYSICAL
		DamageType.MAGICAL: return ActionType.DAMAGE_MAGICAL
		DamageType.POISON: return ActionType.DAMAGE_POISON
		DamageType.PURE: return ActionType.DAMAGE_PURE
		_: return ActionType.DAMAGE_PHYSICAL


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
		ActionType.UTILITY_STUN,
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


func is_randomize_modifier_active(chance_in_percent: float) -> bool:
	return rng.randf_range(0, 100) <= chance_in_percent


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
