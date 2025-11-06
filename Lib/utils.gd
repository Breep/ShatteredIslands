extends Node

# ============================== Enums ==============================
#region Enums
enum DamageType {
	PHYSICAL,
	MAGICAL,
	POISON,
	HEAL,
}

enum PercentModifier {
	MAX_HP,
	CURRENT_HP,
	LOST_HP,
}

enum StackType {
	POISON,
	ARMOR,
	IGNITE,
	REGEN
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
	DamageType.POISON: Color.WEB_GREEN,
	DamageType.HEAL: Color.AQUAMARINE
}

const STACK_COLORS: Dictionary[StackType, Color] = {
	StackType.POISON: Color.WEB_GREEN,
	StackType.ARMOR: Color.SADDLE_BROWN,
	StackType.IGNITE: Color.DARK_RED
}
#endregion

# ============================== Public variables ==============================

@onready var rng := RandomNumberGenerator.new()

# ============================== Private variables ==============================

var _seed: int = 42

# ============================== Node base functions ==============================

func _ready() -> void:
	rng.randomize()

# ============================== Public functions ==============================

func create_perpetual_timer(node: Node, wait_time: float, callback: Callable, autostart: bool = false) -> Timer:
	var timer := Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	node.add_child(timer)
	timer.timeout.connect(callback)
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
