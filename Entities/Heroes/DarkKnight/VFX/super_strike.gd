extends Node3D

func _on_free_timer_timeout() -> void:
	if not is_queued_for_deletion():
		queue_free()
