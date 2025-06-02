class_name PickableCollider
extends Area3D

# Avoid Pickable to overlapped each other

signal overlapped() # Something is overlapping
signal freed() # Nothing is overlapping

var _pickable_collider_overlapping_counter: int = 0: # Number of pickable constraint currently overlapping
	get: return _pickable_collider_overlapping_counter
	set(value):
		if value != _pickable_collider_overlapping_counter:
			_pickable_collider_overlapping_counter = value
			if _pickable_collider_overlapping_counter > 0:
				show()
				overlapped.emit()
			else:
				hide()
				freed.emit()


func _ready() -> void:
	hide()
	Events.game_state_changed.connect(_on_events_game_state_changed)


func _set_active() -> void:
	monitorable = true
	monitoring = true
	_reset()


func _set_inactive() -> void:
	monitorable = false
	monitoring = false
	_reset()


func _reset() -> void:
	hide()
	_pickable_collider_overlapping_counter = 0

func _on_area_entered(area: Area3D) -> void:
	_pickable_collider_overlapping_counter = _pickable_collider_overlapping_counter + 1


func _on_area_exited(area: Area3D) -> void:
	_pickable_collider_overlapping_counter = _pickable_collider_overlapping_counter - 1


func _on_events_game_state_changed(game_state: Game.GameState) -> void:
	if game_state == Game.GameState.FIGHTING:
		_set_active()
	elif game_state == Game.GameState.BUYING:
		_set_inactive()
