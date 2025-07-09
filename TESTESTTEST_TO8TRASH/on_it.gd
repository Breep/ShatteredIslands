extends Node

func _input(event):
	pass
	#if event is InputEventMouseButton:
		#print("[", get_path(), "] MouseClick")
	#if event is InputEventMouseMotion:
		#print("[", get_path(), "] MouseMotion")


func _on_mouse_exited() -> void:
	print("[", get_path(), "] MouseExited")

func _on_mouse_entered() -> void:
	print("[", get_path(), "] MouseEntered")
