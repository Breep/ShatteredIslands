@tool
class_name MainContainer
extends HBoxContainer

enum ContainerPosition {
	LEFT,
	RIGHT
}

@export var _status_container: Control
@export var _stats_container: Control
@export var _left_container: Control
@export var _right_container: Control

var _stats_position: ContainerPosition = ContainerPosition.RIGHT
@export var stats_position: ContainerPosition:
	get: return _stats_position
	set(value):
		if _stats_position == value: return
		_stats_position = value
		if _stats_position == ContainerPosition.LEFT:
			move_child(_stats_container, 0)
			_left_container.hide()
			_right_container.show()
		else:
			move_child(_stats_container, -1)
			_left_container.show()
			_right_container.hide()
		
