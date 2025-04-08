extends Node

# ============================== Enums ==============================

# TODO Quand je vois ces enum ici, je trouve ça moche, mais je sais pas encore où les mettre
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
	VULNERABILITY,
}

# ============================== Public ==============================

func create_perpetual_timer(node: Node, wait_time: float, callback: Callable, autostart: bool = false) -> Timer:
	var timer := Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	node.add_child(timer)
	timer.timeout.connect(callback)
	if autostart:
		timer.start()
	return timer


# TODO move to other lib ?
func is_randomize_modifier_active(chance: float) -> bool:
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100) <= chance


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

# Find the first parent with a specific signal and emit it
func recursive_propagate_signal(node: Node, signal_name: String) -> void:
	if node.has_user_signal(signal_name):
		node.emit_signal(signal_name, self)
	else:
		recursive_propagate_signal(node.get_parent(), signal_name)
