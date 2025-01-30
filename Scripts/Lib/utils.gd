extends Node

func create_optional_timer(node: Node, wait_time: int, callback: Callable) -> void:
	var timer := Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = false
	node.add_child(timer)
	timer.connect("timeout", callback)
	timer.start()
