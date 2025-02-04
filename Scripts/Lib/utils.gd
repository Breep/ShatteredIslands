extends Node

# ============================== Enums ==============================

# TODO Quand je vois ces enum ici, je trouve ça moche, mais je sais pas encore où les mettre
enum DamageType {
	PHYSICAL,
	POISON,
	MAGIC,
}

enum StackType {
	POISON,
	ARMOR,
	VULNERABILITY,
}

# ============================== Public ==============================

func create_optional_timer(node: Node, wait_time: float, callback: Callable) -> Timer:
	var timer := Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	node.add_child(timer)
	timer.connect("timeout", callback)
	timer.start()
	return timer


# TODO move to other lib ?
func is_randomize_modifier_active(chance: float) -> bool:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100) <= chance
