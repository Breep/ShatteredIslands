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
	_set_inactive()
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)


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

func _on_area_entered(_area: Area3D) -> void:
	_pickable_collider_overlapping_counter += 1


func _on_area_exited(_area: Area3D) -> void:
	_pickable_collider_overlapping_counter -= 1


func _on_gfm_fighting_phase_state_changed(fighting_phase_state: GlobalFightingManager.FightingPhaseState) -> void:
	match fighting_phase_state:
		GlobalFightingManager.FightingPhaseState.POSITIONING:
			_set_active()
		_:
			_set_inactive()
