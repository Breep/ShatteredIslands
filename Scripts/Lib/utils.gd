extends Node

# ============================== Enums ==============================

# TODO Quand je vois ces enum ici, je trouve ça moche, mais je sais pas encore où les mettre
enum DamageType {
	PHYSICAL,
	POISON,
	MAGIC,
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
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100) <= chance
